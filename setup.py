import os
import os.path
import pathlib
import platform
import re
import shutil
import subprocess
import sys

from setuptools import Extension, setup
from setuptools.command.build_ext import build_ext
from setuptools.command.sdist import sdist

# Platform check
if sys.platform in ("win32", "cygwin", "cli"):
    raise RuntimeError("asyncfiles does not support Windows at the moment")


CYTHON_DEPENDENCY = "Cython~=3.0"
MACHINE = platform.machine()
MODULES_CFLAGS = [os.getenv("ASYNCFILES_OPT_CFLAGS", "-O3")]
_ROOT = pathlib.Path(__file__).parent
LIBUV_DIR = str(_ROOT / "vendor" / "libuv")
LIBUV_BUILD_DIR = str(_ROOT / "build" / "libuv-{}".format(MACHINE))


def _libuv_build_env():
    """Prepare environment for building libuv"""
    env = os.environ.copy()

    cur_cflags = env.get("CFLAGS", "")
    if not re.search(r"-O\d", cur_cflags):
        cur_cflags += " -O2"

    env["CFLAGS"] = cur_cflags + " -fPIC " + env.get("ARCHFLAGS", "")

    return env


def _libuv_autogen(env):
    """Run libuv autogen if needed"""
    if os.path.exists(os.path.join(LIBUV_DIR, "configure")):
        # No need to use autogen, the configure script is there.
        return

    if not os.path.exists(os.path.join(LIBUV_DIR, "autogen.sh")):
        raise RuntimeError(
            "the libuv submodule has not been checked out; "
            'try running "git submodule init; git submodule update"'
        )

    subprocess.run(["/bin/sh", "autogen.sh"], cwd=LIBUV_DIR, env=env, check=True)


class asyncfiles_sdist(sdist):
    """Custom sdist command that builds libuv configure"""

    def run(self):
        _libuv_autogen(_libuv_build_env())
        super().run()


class asyncfiles_build_ext(build_ext):
    """Custom build_ext command for building Cython extensions and libuv"""

    user_options = build_ext.user_options + [
        ("cython-always", None, "run cythonize() even if .c files are present"),
        (
            "cython-annotate",
            None,
            "Produce a colorized HTML version of the Cython source.",
        ),
        ("cython-directives=", None, "Cython compiler directives"),
        (
            "use-system-libuv",
            None,
            "Use the system provided libuv, instead of the bundled one",
        ),
    ]

    boolean_options = build_ext.boolean_options + [
        "cython-always",
        "cython-annotate",
        "use-system-libuv",
    ]

    def initialize_options(self):
        super().initialize_options()
        self.use_system_libuv = False
        self.cython_always = False
        self.cython_annotate = None
        self.cython_directives = None

    def finalize_options(self):
        need_cythonize = self.cython_always
        cfiles = {}

        for extension in self.distribution.ext_modules:
            for i, sfile in enumerate(extension.sources):
                if sfile.endswith(".pyx"):
                    prefix, _ = os.path.splitext(sfile)
                    cfile = prefix + ".c"

                    if os.path.exists(cfile) and not self.cython_always:
                        extension.sources[i] = cfile
                    else:
                        cfiles[cfile] = (
                            os.path.getmtime(cfile) if os.path.exists(cfile) else 0
                        )
                        need_cythonize = True

        if need_cythonize:
            import pkg_resources

            # Double check Cython presence in case setup_requires
            # didn't go into effect
            try:
                import Cython
            except ImportError:
                raise RuntimeError(
                    "please install {} to compile asyncfiles from source".format(
                        CYTHON_DEPENDENCY
                    )
                )

            cython_dep = pkg_resources.Requirement.parse(CYTHON_DEPENDENCY)
            if Cython.__version__ not in cython_dep:
                raise RuntimeError(
                    "asyncfiles requires {}, got Cython=={}".format(
                        CYTHON_DEPENDENCY, Cython.__version__
                    )
                )

            from Cython.Build import cythonize

            directives = {}
            if self.cython_directives:
                for directive in self.cython_directives.split(","):
                    k, _, v = directive.partition("=")
                    if v.lower() == "false":
                        v = False
                    if v.lower() == "true":
                        v = True
                    directives[k] = v
                self.cython_directives = directives
                    

            self.distribution.ext_modules[:] = cythonize(
                self.distribution.ext_modules,
                compiler_directives=directives,
                annotate=self.cython_annotate,
                emit_linenums=self.debug,
            )

        super().finalize_options()

    def build_libuv(self):
        """Build libuv from source"""
        env = _libuv_build_env()

        _libuv_autogen(env)

        # Copy the libuv tree to build/ so that its build
        # products don't pollute sdist accidentally.
        if os.path.exists(LIBUV_BUILD_DIR):
            shutil.rmtree(LIBUV_BUILD_DIR)
        shutil.copytree(LIBUV_DIR, LIBUV_BUILD_DIR)

        # Touch files to prevent autoreconf
        subprocess.run(
            [
                "touch",
                "configure.ac",
                "aclocal.m4",
                "configure",
                "Makefile.am",
                "Makefile.in",
            ],
            cwd=LIBUV_BUILD_DIR,
            env=env,
            check=True,
        )

        # Configure libuv
        if "LIBUV_CONFIGURE_HOST" in env:
            cmd = ["./configure", "--host=" + env["LIBUV_CONFIGURE_HOST"]]
        else:
            cmd = ["./configure"]
        subprocess.run(cmd, cwd=LIBUV_BUILD_DIR, env=env, check=True)

        # Build libuv with parallel jobs
        try:
            njobs = len(os.sched_getaffinity(0))
        except AttributeError:
            njobs = os.cpu_count()
        j_flag = "-j{}".format(njobs or 1)
        c_flag = "CFLAGS={}".format(env["CFLAGS"])
        subprocess.run(
            ["make", j_flag, c_flag], cwd=LIBUV_BUILD_DIR, env=env, check=True
        )

    def build_extensions(self):
        if self.use_system_libuv:
            self.compiler.add_library("uv")

            if sys.platform == "darwin" and os.path.exists("/opt/local/include"):
                # Support macports on Mac OS X.
                self.compiler.add_include_dir("/opt/local/include")
        else:
            libuv_lib = os.path.join(LIBUV_BUILD_DIR, ".libs", "libuv.a")
            if not os.path.exists(libuv_lib):
                self.build_libuv()
            if not os.path.exists(libuv_lib):
                raise RuntimeError("failed to build libuv")

            # Add libuv to all extensions
            for ext in self.extensions:
                ext.extra_objects.append(libuv_lib)

            self.compiler.add_include_dir(os.path.join(LIBUV_DIR, "include"))

        # Platform-specific libraries
        if sys.platform.startswith("linux"):
            self.compiler.add_library("rt")
        elif sys.platform.startswith(("freebsd", "dragonfly")):
            self.compiler.add_library("kvm")
        elif sys.platform.startswith("sunos"):
            self.compiler.add_library("kstat")

        self.compiler.add_library("pthread")

        super().build_extensions()


# Setup requirements
setup_requires = []
if "--cython-always" in sys.argv or not all(
    os.path.exists(f"asyncfiles/{name}.c") for name in ["utils", "files", "callbacks"]
):
    setup_requires.append(CYTHON_DEPENDENCY)


setup(
    name="asyncfiles",
    version="0.1.0",
    description="High-performance async file I/O library built on libuv",
    long_description=open("README.md").read() if os.path.exists("README.md") else "",
    long_description_content_type="text/markdown",
    author="Your Name",
    author_email="your.email@example.com",
    url="https://github.com/yourusername/asyncfiles",
    license="MIT",
    platforms=["POSIX"],
    python_requires=">=3.8",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: POSIX",
        "Operating System :: MacOS",
        "Operating System :: Unix",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Programming Language :: Python :: Implementation :: CPython",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Framework :: AsyncIO",
    ],
    packages=["asyncfiles"],
    cmdclass={"sdist": asyncfiles_sdist, "build_ext": asyncfiles_build_ext},
    ext_modules=[
        Extension(
            "asyncfiles.utils",
            sources=["asyncfiles/utils.pyx"],
            extra_compile_args=MODULES_CFLAGS,
        ),
        Extension(
            "asyncfiles.files",
            sources=["asyncfiles/files.pyx"],
            extra_compile_args=MODULES_CFLAGS,
        ),
        Extension(
            "asyncfiles.callbacks",
            sources=["asyncfiles/callbacks.pyx"],
            extra_compile_args=MODULES_CFLAGS,
        ),
    ],
    setup_requires=setup_requires,
    install_requires=[],
    extras_require={
        "dev": [
            "pytest>=7.0",
            "pytest-asyncio>=0.21.0",
            CYTHON_DEPENDENCY,
        ],
    },
    include_package_data=True,
    zip_safe=False,
)
