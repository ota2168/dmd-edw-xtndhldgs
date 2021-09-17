Using Pre-Commit
================
``pre-commit`` is a program used to configure and run Git hooks. These hooks can be triggered in different Git stages,
though typically we use them in only commit and push stages.

Read more about ``pre-commit`` here: `<https://pre-commit.com>`_
Read about the contents of our ``.pre-commit-config.yaml`` here: `Pre Commit Config <pre_commit_config_yaml_contents.rst>`_

Each of the hooks will run in its own small virtual environment.

Setup
-----
The program must be installed and the hooks must be configured. THe program should be installed in your projects
virtual environment, which I will assume is named "venv".

The below terminal commands will accomplish this:

.. code-block:: bash

    (venv) $ pip install pre-commit
    (venv) $ pre-commit autoupdate
    (venv) $ pre-commit install
    (venv) $ pre-commit install --hook-type pre-push

This can also be accomplished through the use of our Makefile:

.. code-block:: bash

    (venv) $ make _install_hooks

Automatic Usage
---------------
In normal usage, ``pre-commit`` will trigger with every ``git commit`` and every ``git push``. The hooks that trigger
in each stage can be configured by editing the ``.pre-commit-config.yaml`` file. The files that have changed
will be passed to the various hooks before the git operation completes. If one of the hooks exits with a non-zero
exit-code, then the commit (or push) will fail.

Manual Usage
------------
To manually trigger ``pre-commit`` to run all hooks on CHANGED files:

.. code-block:: bash

    (venv) $ pre-commit run

To manually trigger ``pre-commit`` to run all hooks on ALL files, regardless of if they are changed or not:

.. code-block:: bash

    (venv) $ pre-commit run --all-files

The above is equivalent to
.. code-block:: bash

    (venv) $ make hooks

To manually trigger ``pre-commit`` to run a single hook on changed files:

.. code-block:: bash

    (venv) $ pre-commit run <hook-id>

To manually trigger `pre-commit`` to run a single hook on all files:

.. code-block:: bash

    (venv) $ pre-commit run <hook-id> --all-files

For example, to run ``black`` on all files:

.. code-block:: bash

    (venv) $ pre-commit run black --all-files

Skipping Pre-Commit
-------------------
It is possible to skip ``pre-commit``. If you would like to do so then read the ``pre-commit`` documentation.
