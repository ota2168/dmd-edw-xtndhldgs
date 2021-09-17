Contents of the ``tox.ini`` file
================================

Each section in ``tox.ini`` file has a purpose. We use ``tox`` for running tests, it stores its configuration here.
Other programs also store their configuration in ``tox.ini``.

Read more about ``tox`` here: `<https://tox.readthedocs.io/en/latest/>`_

This document will review the various sections and variables of ``tox.ini``.

``[tox]``
---------
The section ``[tox]`` details the default environments for tox as well as other ``tox`` specific instructions.

.. code-block:: INI

    [tox]
    envlist = clean,build,py{36,37},pydocstyle,black,flake8,mypy
    skip_missing_interpreters = true

tox commands
''''''''''''
``envlist``
```````````
When invoked with no arguments, ``tox`` executes all the environments in ``envlist``:

Example: Execute on all environments

.. code-block:: bash

    $ tox

``skip_missing_interpreters``
`````````````````````````````
This tells ``tox`` that it is allright if one of the interpreters, for example Python3.7, is missing.

``[testenv]``
-------------
The section ``[testenv]`` details the primary testing environment.

.. code-block:: INI

    [testenv]
    skip_install = true
    deps:
        pytest
        pytest-cov
    commands =
        /bin/bash -c 'python -m pip install {env:WORKSPACE:{toxinidir}}/dist/*tar.gz'
        pytest --junitxml={env:WORKSPACE:{toxinidir}}/test_results/{envname}.xml

Environments named like ``py35`` or ``py36`` designate the version of the Python interpreter, where ``py35``
indicates Python 3.5 for example. When they are executed, ``tox`` will use that Python interpreter to execute
the ``tox`` section ``[testenv]``. This allows us to setup a single ``[testenv]`` and test it on multiple versions of
Python.

Example: Execute ``[testenv]`` on Python 3.5 and Python 3.6

.. code-block:: bash

    $ tox -e py35,py36


tox commands
''''''''''''
``skip_install``
````````````````
When set to true, this flag will tell ``tox`` to not install the current package. This is usefull if an environment
does not need to install the package (saves time) or if we want more control over installation.

``deps``
````````
This multi-line list details the various dependencies which should be installed in the envioronment. In this generic
``[testenv]`` we require ``pytest`` and ``pytest-cov``. Depending on the environment these values will change.

``commands``
````````````
A list of commands to execute in the environment.
In this example of ``[testenv]`` we want to install a built Python artifact, specifcally one at the location
``{env:WORKSPACE:{toxinidir}}/dist/*tar.gz``. In addition we want to run ``pytest`` and have it generate a JUnit XML
test report.

variables
'''''''''

``{toxinidir}``
```````````````
This will be populated with the directory where ``tox.ini`` is located.

``{env:WORKSPACE:<dir>}``
`````````````````````````
This will be populated with the path to the workspace, useful for JenkinsX.

``{envname}``
`````````````
This will be populated with the name of the current environment, for example ``py35``.

``[testenv:clean]``
-------------------
The section ``[testenv:clean]`` details the settings for the tox environment ``clean``. This simply uses ``coverage``
 to erase previously collected coverage data.

.. code-block:: INI

    [testenv:clean]
    skip_install = true
    deps =
        coverage
    commands =
        coverage erase

``[testenv:build]``
-------------------
The section ``[testenv:build]`` details the settings for the tox environment ``build``. It takes the current
package and uses ``python setup.py`` to create a ``<package_name>.tar.gz`` file. This is the built artifact which
can later be installed or uploaded to Python package repositories.

.. code-block:: INI

    [testenv:build]
    basepython = python3.6
    skip_install = true
    deps =
        setuptools
        twine
        wheel
    commands =
        python setup.py check -q \
        sdist --dist-dir={env:WORKSPACE:{toxinidir}}/dist \
        bdist_wheel --dist-dir={env:WORKSPACE:{toxinidir}}/dist

tox commands
''''''''''''
``basepython``
``````````````
This sets the python interpereter to be used for this tox environment.


``[testenv:pydocstyle]``
------------------------
The section ``[testenv:pydocstyle]`` details the settings for the tox environment ``pydocstyle``. It runs the program
 ``pydocstyle``, a Python docstring style checker.

 Read more about ``pydocstyle`` here: `<http://www.pydocstyle.org/en/4.0.1/>`_

.. code-block:: INI

    [testenv:pydocstyle]
    basepython = python3.6
    skip_install = true
    deps =
        pydocstyle
    commands =
         pydocstyle \
        {env:WORKSPACE:{toxinidir}}/src/ \
        {env:WORKSPACE:{toxinidir}}/tests/ \
        {env:WORKSPACE:{toxinidir}}/setup.py

Here in the `commands`, we invoke `pydocstyle` on three places, the `./src` directory, the `./tests/` directory and
the file `./setup.py`. This pattern of running a program on these three locations is repeated throughout ``tox.ini``.

``[testenv:black]``
-------------------
The section ``[testenv:black]`` details the settings for the tox environment ``black``. It runs the program
``black``, a Python code formatter.

Read more about ``black`` here: `<https://black.readthedocs.io/en/stable/>`_

.. code-block:: INI

    [testenv:black]
    basepython = python3.6
    skip_install = true
    deps =
        black>=19.3b0
    commands =
        black -l 120 --check --diff \
        {env:WORKSPACE:{toxinidir}}/src/ \
        {env:WORKSPACE:{toxinidir}}/tests/ \
        {env:WORKSPACE:{toxinidir}}/setup.py

Here we tell ``black`` to use  ``-l 120`` which sets the line length to 120 characters. By setting ``--check``, we
tell ``black`` to not chagne any formatting, only to check that formatting is correct. The argument ``--diff`` will
cause ``black`` to display any required changes. The files checked are the same as in other sections.

``[testenv:flake8]``
--------------------
The section ``[testenv:flake8]`` details the settings for the tox environment ``flake8``. It runs the program
``flake8``, a Python code linter.

Read more about ``flake8`` here: `<http://flake8.pycqa.org/en/latest/>`_

.. code-block:: INI

    [testenv:flake8]
    basepython = python3.6
    skip_install = true
    deps =
        flake8
        flake8_formatter_junit_xml
    commands =
        /bin/bash -c 'mkdir -p {env:WORKSPACE:{toxinidir}}/test_results'
        flake8 \
        --format=junit-xml \
        --output={env:WORKSPACE:{toxinidir}}/test_results/{envname}.xml \
        {env:WORKSPACE:{toxinidir}}/src/ \
        {env:WORKSPACE:{toxinidir}}/tests/ \
        {env:WORKSPACE:{toxinidir}}/setup.py

Here we tell ``flake8`` to output a "JUnit" format XML file, which contains test results, and to write it to the
location detailed in ``--output``. The files checked are the same as in other sections.

Read more about JUnit here: `<https://llg.cubic.org/docs/junit/>`_

``[testenv:mypy]``
-------------------
The section ``[testenv:mypy]`` details the settings for the tox environment ``mypy``. It runs the program
``mypy``, a Python static type checker.

.. code-block:: INI

    [testenv:mypy]
    basepython = python3.6
    skip_install = true
    deps =
        mypy
    commands =
        mypy \
        --ignore-missing-imports \
        --junit-xml={env:WORKSPACE:{toxinidir}}/test_results/{envname}.xml \
        {env:WORKSPACE:{toxinidir}}/src/ \
        {env:WORKSPACE:{toxinidir}}/tests/ \
        {env:WORKSPACE:{toxinidir}}/setup.py

Here we tell ``mypy`` to output a "JUnit" format XML file and to write it to the location indicated. The files
checked are the same as in other sections.

Read more about ``mypy`` here: `<http://mypy-lang.org/>`


****

The below sections are used to configure programs used by ``tox``, and other programs.

These configurations are used by these programs if they are invoked inside ``tox`` OR outside ``tox``.

``[pytest]``
------------
This section is used to configure ``pytest``. The items in ``addopts`` are arguments passed to ``pytest`` when it is
invoked. In particular these tell ``pytest`` to produce multiple coverage reports, and the last item ``--cov=``
details the pacakge to test (``PACKAGENAME``) and which tests to run (``tests/``).

.. code-block:: INI

    [pytest]
    addopts =
        --cov-branch
        --cov-report=term-missing
        --cov-report=html
        --cov-report=xml
        --cov-append
        --cov=PACKAGENAME tests/

    filterwarnings =
        ignore::DeprecationWarning
        ignore::PendingDeprecationWarning

    junit_family =
        xunit2

``[pydocstyle]``
----------------
This section is used to configure ``pydocstyle``. We can set ``match`` to be a regex of files to examine.

.. code-block:: INI

    [pydocstyle]
    inherit = false
    match = (?!.*(test_|__version__)).*\.py

``[coverage:****]``
-------------------
Multiple ``[coverage: ]`` sections exist, these are settings for the program ``coverage`` which is used by
``pytest-cov`` to generate test coverage reports.

Read more about ``coverage`` here: `<https://coverage.readthedocs.io/en/v4.5.x/index.html>`_
Read more about ``pytest-cov`` here: `<https://pytest-cov.readthedocs.io/en/latest/>`_

``[flake8]``
------------
This section is used to configure ``flake8``. The settings here must be carefully coordinated so as to not interfere
with ``black``. By setting ``max-complexity`` we can control th maximum amoout of allowed branching.

.. code-block:: INI

    ignore = E203, E266, E501, W503, F403, F401
    max-line-length = 120
    max-complexity = 7
    select = B,C,E,F,W,T4,B9

``[isort]``
------------
This section is used to configure ``isort``. Isort is used to sort the imports in Python scripts. The item listed in
``forced_separate`` should be the current package, while ``known_first_party`` should be internal MassMutual programs.

Read more about ``isort`` here: `<https://isort.readthedocs.io/en/latest/>`_

.. code-block:: INI

    [isort]
    known_first_party = dmd_aws_io,meta_fin,utility_mixins,PACKAGENAME
    known_third_party = docopt,setuptools,templatepackage
    forced_separate = PACKAGENAME
    line_length = 120
    force_single_line = True
    order_by_type = True
    lines_between_types = 1
    force_sort_within_sections = False
