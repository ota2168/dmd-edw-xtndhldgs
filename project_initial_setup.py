"""Project initial setup."""

import sys

from pathlib import Path
from typing import Dict


def get_codeowner() -> str:
    codeowner = input("Enter project owner GitHub ID (ex: @massmutual/edap) :\n").strip()
    if not codeowner.startswith("@"):
        codeowner = "@" + codeowner
    return codeowner


def get_email() -> str:
    return input("Enter email (ex: asheridan25@massmutual.com) :\n").strip()


def get_packagename() -> str:
    package_name = input("Enter name of new package (ex: foo_bar) :\n").strip()
    package_name = package_name.lower().replace("-", "_")
    if package_name[0].isdigit():
        print("Package name cannot start with a number")
        exit(1)
    if not package_name.replace("_", "").isalnum():
        print("Invalid package name")
        exit(1)
    return package_name


def edit_file(path: Path, params: Dict):
    contents = path.read_text()
    for key, value in params.items():
        contents = contents.replace(key, value)
    path.write_text(contents)
    return None


def edit_codeowners(codeowner: str) -> None:
    path = Path("./.github/CODEOWNERS")
    params = {"{{ CODEOWNER }}": codeowner}
    edit_file(path, params)
    return None


def rename_package(name: str, owner: str, codeowner: str, email: str) -> None:
    old_path = Path("./src/{{ PACKAGENAME }}")
    new_path = Path(f"./src/{name}")
    old_path.rename(new_path)

    params = {
        "__packagename__": name,
        "{{ PACKAGENAME }}": name,
        "{{ PACKAGENAMECLI }}": name.replace("_", "-"),
        "{{ CODEOWNER }}": codeowner,
        "{{ OWNER }}": owner,
        "{{ EMAIL }}": email,
        "{{ REPONAME }}": Path.cwd().stem,
    }
    edit_file(new_path / "cli.py", params)
    edit_file(Path("tests") / "test_cli.py", params)
    edit_file(Path("setup.py"), params)
    edit_file(Path("tox.ini"), params)
    edit_file(Path("Jenkinsfile"), params)
    edit_file(Path("Makefile"), params)


def adjust_python_version_strings():
    major, minor = sys.version_info.major, sys.version_info.minor

    version = str(major) + "." + str(minor)

    params = {"{{ PYTHONVERSIONLONG }}": version, "{{ PYTHONVERSIONSHORT }}": version.replace(".", "")}
    edit_file(Path("setup.py"), params)
    edit_file(Path("tox.ini"), params)
    edit_file(Path("Jenkinsfile"), params)
    edit_file(Path(".pre-commit-config.yaml"), params)


def main():
    codeowner = get_codeowner()
    edit_codeowners(codeowner)

    email = input("Enter email (ex: asheridan25@massmutual.com) :\n").strip()
    owner = input("Enter name (ex: Andrew Sheridan) :\n").strip()
    name = get_packagename()
    rename_package(name, owner, codeowner, email)
    adjust_python_version_strings()


if __name__ == "__main__":
    main()
