pipeline {
    agent {
        kubernetes {
            label 'edwxtndhldgs'
            defaultContainer 'default'
            yamlFile 'ci/pod.yaml'
        }
    }
    environment {
        APP_NAME = 'edwxtndhldgs_etl'
        ARTIFACT_DIR = 'dist/'
    }
    options {
        buildDiscarder(logRotator(daysToKeepStr: '7'))
        disableResume()
        timeout(time: 30, unit: 'MINUTES')
    }
    stages {
        stage('Start') {
            steps {
                script {
                    slack.configAndSendMessage(getJxUrl: false, slackColor: '', slackMessage: 'pipeline started')
                }
            }
        }
        stage('Pre-Build') {
            environment {
                TOX_ENVS = 'pre-commit-lint,black,flake8,mypy,isort'
            }
            steps {
                echo 'Pre-build'
                sh './ci/run-tox-parallel.sh'
            }
        }
        stage('Build') {
            environment {
                TOX_ENVS = 'clean,build'
            }
            steps {
                echo 'Building'
                sh './ci/run-tox.sh'
            }
        }
        stage('Test') {
            environment {
                // feel free tox add more python versions here
                TOX_ENVS = 'py37'
            }
            steps {
                echo 'Testing'
                sh './ci/run-tox.sh'
            }
        }
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
    }
    post {
        always {
            echo 'Collecting all available junit tests'
            junit(allowEmptyResults: true, testResults: 'test_results/*.xml')
        }
        aborted {
            echo 'Build aborted'
            script {
                slack.configAndSendMessage(getJxUrl: false, slackColor: 'danger', slackMessage: 'Pipeline aborted')
            }
        }
        success {
            echo 'Build succeeded'
            script {
                slack.configAndSendMessage(getJxUrl: false, slackColor: 'good', slackMessage: 'Pipeline succeeded')
            }
        }
        failure {
            echo 'Build failed'
            script {
                slack.configAndSendMessage(getJxUrl: false, slackColor: 'danger', slackMessage: 'Pipeline failed')
            }
        }
        unstable {
            echo 'Build unstable'
            script {
                slack.configAndSendMessage(getJxUrl: false, slackColor: 'danger', slackMessage: 'Pipeline unstable')
            }
        }
        fixed {
            echo 'Build fixed'
            script {
                slack.configAndSendMessage(getJxUrl: false, slackColor: 'good', slackMessage: 'Pipeline fixed')
            }
        }
        cleanup {
            echo 'Cleanup'
            cleanWs()
        }
    }
}
