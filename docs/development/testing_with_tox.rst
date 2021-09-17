Using ``tox``
=============
``tox`` is a program to run tests in virutal environments.

Read more about ``tox`` here: `<https://tox.readthedocs.io/en/latest/>`_
Read about the contents of our ``tox.ini`` here: `Tox INI <tox_ini_contents.rst>`_

Running in your terminal
------------------------
Basic settings, all environments
''''''''''''''''''''''''''''''''
.. code-block:: bash

    (venv) $ tox

This will run ``tox`` according to the configuration of its ``tox.ini``, running the ``[testenv]`` against the
available Python interpreters that are listed in the ``envlist``.

Specific environments
'''''''''''''''''''''''''''''''''''''
Pass in the argument ``-e ENV_LIST`` to set specific environments.

.. code-block:: bash

    (venv) $ tox -e black,mypy,flake8

This will run ``tox`` according to the configuration of its ``tox.ini``, running the environments ``[black]``,
``[mypy]``, and ``[flake8]``.

Test in parallel
''''''''''''''''
Pass in the argument ``--parallel=auto`` to run tox in parallel. ``auto`` can be substitued for an integer number of
concurrency.

.. code-block:: bash

    (venv) $ tox --parallel=auto -e py35,py36

This will run ``tox`` in parallel, according to the configuration of its ``tox.ini``, running the ``[testenv]`` against
the Python interpreters Python3.5 and Python3.6, assuming they are available.


Running in Docker
-----------------
See the document ``testing_in_docker.rst`` here: `Testing in Docker <testing_in_docker.rst>`_

Test Results
------------
Test results are written to a directory named ``test_results``. Coverage reports are written to a directory names
``coverage_html``. These directory names can be configured in ``tox.ini``.
