Testing in Docker
=================
Our tests can be run in Docker. A file ``./ci/local-docker-tests.sh`` is provided which enables this.

Setup
-----
Docker must be installed in your system and activated, then:

.. code-block:: bash

    $ source test-setup.sh

This will make the following functions available:

- run
- run_tests

``run``
-------
This allows us to run arbitrary commands inside the Docker container.

``run_dtests``
-------------
This will run our tests in the Docker Container.
The setup (clean & build) run sequentially, then the interpreters run in parallel.
This can be configured in ``./ci/local-docker-tests.sh``

Test Results
------------
Test results are written to a directory named ``./test_results``.
Coverage reports are written to a directory names ``./coverage_html``.
These directory names can be configured in ``tox.ini``.
Open ``./coverage_html/index.html`` in a browser to view detailed results.
