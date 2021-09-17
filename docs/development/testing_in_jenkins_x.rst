Testing in JenkinsX
===================
Testing in JenkinsX is facilitated by our Jenkinsfile, which lays out the various stages of our pipeline.

Read about Jenkinsfiles here: `<https://jenkins.io/doc/book/pipeline/jenkinsfile>`

Editing the Jenkinsfile will change the bevaior of the testing pipeline, the number and operation of the stages is
entirely up to you. Here we will one configuration.

To setup your repo to integrate with JenkinsX please reach out to Andrew Sheridan or Michael Anselmi.

Agent
-----
.. code-block:: groovy

    agent {
        kubernetes {
            label 'PACKAGENAME'
            defaultContainer 'default'
            yamlFile 'ci/pod.yaml'
        }
    }

The agent section defines where the tests will be run. Here we declare a Kubernetes agaent that will run the
container defined in ``ci/pod.yaml``.


Stages
------
Start
'''''
.. code-block:: groovy

    stage('Start') {
        steps {
            script {
                slack.configAndSendMessage(getJxUrl: false, slackColor: '', slackMessage: 'pipeline started')
            }
        }
    }

The Start stage simply sends out a slack message that indicates the start of the pipeline. The slack channel is
defined in the file ``.slackSettings``

Pre-Build
'''''''''
.. code-block:: groovy

    stage('Pre-Build') {
        environment {
            TOX_ENVS = 'pydocstyle,black,flake8,mypy'
        }
        steps {
            echo 'Pre-build'
            sh './ci/run-tox-parallel.sh'
        }
    }

The Pre-Build stage runs the various style checkers and linters in parallel. The configuration for these is taken from
the ``tox.ini`` file.

Build
'''''
.. code-block:: groovy

    stage('Build') {
        environment {
            TOX_ENVS = 'clean,build'
        }
        steps {
            echo 'Building'
            sh './ci/run-tox.sh'
        }
    }

The Build stage builds an installer from the current pacakge.

Test
''''
.. code-block:: groovy

    stage('Test') {
        environment {
            TOX_ENVS = 'py35,py36,py37'
        }
        steps {
            echo 'Testing'
            sh './ci/run-tox-parallel.sh'
        }
    }

The test stage installs the built package and tests it in parallel against multplile versions of Python. It writes
test results that can be viewed in Jenkins.

Deploy
''''''
.. code-block:: groovy

    stage('Deploy') {
        when {
            beforeAgent true
            branch 'master'
        }
        steps {
            echo 'Deploying'
            withCredentials([usernamePassword(credentialsId: 'jx-pipeline-release-artifactory', passwordVariable: 'TWINE_PASSWORD', usernameVariable: 'TWINE_USERNAME')]) {
              sh './ci/deploy.sh'
            }
            script {
                slack.configAndSendMessage(getJxUrl: false, slackColor: 'good', slackMessage: 'deploy succeeded')
            }
        }
    }

The Deploy stage will check to see if the current branch is ``master``. It is not then Jenkins skips to the end. If
it is the ``master`` branch, then Jenkins will attempt to deploy the built artifact to MassMutuals Artifactory. The
logic governing this deployment process is defined in ``ci/deploy.sh``. In particular, the version of the new
artifact my be different from any already deployed version.

Post Testing
------------
After the CI process, the Post section is executed. Here we collect our tests, issue messages, and cleanup.
