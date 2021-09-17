"""Utils."""

import shutil

from pathlib import Path

from utility_mixins import PathMixin


def unpack_sql_into_cwd(package_name: str):
    """Remove the sql dir and replace with the sql embedded in the app."""
    print("unpacking sql")
    cwd = Path.cwd()
    sql_target_dir = cwd / "sql"
    sql_source_dir = PathMixin().get_internal_path(package_name, "sql")

    if sql_target_dir.exists():
        shutil.rmtree(sql_target_dir)
    shutil.copytree(str(sql_source_dir), str(sql_target_dir))
    return None
