Contents of the ``.pre-commit-config.yaml`` file
================================================

The file ``.pre-commit-config.yaml`` is used to configure the program ``pre-commit``, which controls the setup and
execution of Git hooks.

Read more about ``pre-commit`` here: `<https://pre-commit.com>`_

Git hooks are used to execute small scripts when performing git actions. They can be manually configured, but using
``pre-commit`` is easier and quite flexible.

Read more about ``git-hooks`` here: `<https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks>`_

``.pre-commit-config.yaml`` has a list of git repos, each repo may define one or more hooks.

In this document we will review the various hooks. Some of the hooks will modify files, some will not.


``end-of-file-fixer``
---------------------
This will modify files by making sure that each file ends in a blank line.

If a commit fails due to this hook, just commit again.


``trailing-whitespace``
-----------------------
This will modify files by ensuring there is no trailing whitespace on any line.

If a commit fails due to this hook, just commit again.

``seed-isort-config``
---------------------
This will modify the file ``tox.ini``. It examines all changed Python files and compares the imports to the lists
``known_first_party`` and ``known_third_party`` parts of the ``isort`` section in the ``tox.ini`` file. When new
items are imported they are added to the lists in alphabetical order.

If a commit fails due to this hook, check ``tox.ini`` to ensure the lists are correct (``seed-isort-config`` guesses
as to what is first party (internal MassMutual packages) and what is third party ( packages not from MassMutual, and
not part of the Python Standard Library.

``isort``
---------
This will modify Python files by re-ordering the imports. The rules for the re-ordering are defined in ``tox.ini``.

If a commit fails due to this hook, just commit again.

``black``
---------
This will modify Python files by re-formatting the code. The rules for the formatting are defined in
``.pre-commit-config.yaml`` in the ``args`` section, and must match the rules in ``tox.ini`` (for example the line-length must be the same).

If a commit fails due to this hook, just commit again.


``beautysh``
------------------
This will modify files. It will examine shell files and fix some formatting issues. The rules for its configuration
are defined in ``.pre-commit-config.yaml`` in the ``args`` section.

If a commit fails due to this hook, just commit again.


``pydocstyle``
--------------
This will NOT modify files. It will examine the docstrings in Python modules, classes, and functions. Any issues will
 be reported. The rules for this are defined in ``tox.ini``.

If a commit fails due to this hook, all reported issues must be manually fixed before commiting again.

``check-byte-order-marker``
---------------------------
This will NOT modify files. It will examine files for Byte Order Marks, and report any issues.

If a commit fails due to this hook either remove the Byte Order Marks, or remove the offending file, before
committing again.

``flake8``
----------
This will NOT modify files. It will examine Python files for adherence to PEP8 and report any issues. Typically
``black`` will correct any issues that ``flake8`` may find.  The rules for this are defined in ``tox.ini``, and must
be carefully selected to be compatible with ``black``.

If a commit fails due to this hook, all reported issues must be manually fixed before committing again.

``mypy``
--------
This will NOT modify files. It will examine Python files for typing inconsistencies and report any issues. The rules
for its configuration are defined in ``.pre-commit-config.yaml`` in the ``args`` section and must match the rules in ``tox.ini``.

If a commit fails due to this hook, all reported issues must be manually fixed before committing again.

``yamllint``
------------
This will NOT modifiy files. It will examine YAML files and report any issues. The rules for its configuration are
defined in ``.pre-commit-config.yaml`` in the ``args`` section.

If a commit fails due to this hook, all reported issues must be manually fixed before committing again.


``dockerfilelint``
------------------
This will NOT modifiy files. It will examine Dockerfile files and report any issues. The rules for its configuration
are defined in ``.pre-commit-config.yaml`` in the ``args`` section.

If a commit fails due to this hook, all reported issues must be manually fixed before committing again.

``bashate``
------------------
This will NOT modifiy files. It will examine shell files and report any issues. The rules for its configuration
are defined in ``.pre-commit-config.yaml`` in the ``args`` section.

If a commit fails due to this hook, all reported issues must be manually fixed before committing again.
