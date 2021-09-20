"""Setup."""

from pathlib import Path

from setuptools import find_packages
from setuptools import setup

PACKAGE_NAME = "edwxtndhldgs_etl"


def _read(path: str) -> str:
    return Path(path).read_text()


def _generate_version_file() -> None:
    """Generate the package file __version__.py using the development file VERSION."""
    version = _read("./VERSION").strip()
    line = f'__version__ = "{version}"\n'
    path = Path(".") / "src" / PACKAGE_NAME / "__version__.py"
    path.write_text(line)


_generate_version_file()
requirements = _read("./requirements.txt").split()
requirements_dev = _read("./requirements-dev.txt").split()

setup(
    name=PACKAGE_NAME,
    version=_read("./VERSION").strip(),
    description=PACKAGE_NAME,
    long_description=_read("./README.md"),
    author="Amit_Kumar",
    author_email="akumar66@massmutual.com",
    url="https://github.com/massmutual/edwxtndhldgs",
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    zip_safe=False,
    include_package_data=True,
    python_requires=">=3.7",
    entry_points={
        "console_scripts": [
            "edwxtndhldgs-etl = edwxtndhldgs_etl.cli:main"
        ]
    },
    install_requires=requirements,
    extras_require={"dev": requirements_dev,},
)
