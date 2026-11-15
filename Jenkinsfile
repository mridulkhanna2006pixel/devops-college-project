pipeline {
    agent any
    options {
        disableConcurrentBuilds()
        timestamps()
    }
    triggers {
        // Poll GitHub every two minutes; Jenkins builds only when main changes.
        pollSCM('H/2 * * * *')
    }
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out the main branch from GitHub'
                checkout scm
                sh 'git branch --show-current || true'
            }
        }
        stage('Validate') {
            steps {
                echo 'Checking required website files'
                sh '''#!/usr/bin/env bash
                    set -euo pipefail
                    for file in index.html style.css script.js; do
                        if [[ ! -f "$file" ]]; then echo "ERROR: Required file is missing: $file" >&2; exit 1; fi
                        echo "Found $file"
                    done
                '''
            }
        }
        stage('Deploy') {
            steps {
                echo 'Running the restricted deployment helper'
                sh 'bash scripts/deploy.sh'
            }
        }
        stage('Verify') {
            steps {
                echo 'Verifying Nginx and the deployed homepage'
                sh '''#!/usr/bin/env bash
                    set -euo pipefail
                    systemctl is-active --quiet nginx
                    curl --fail --silent --show-error http://127.0.0.1/ -o /tmp/jenkins-deployment-check.html
                    grep -q 'Ship every change' /tmp/jenkins-deployment-check.html
                    echo 'Nginx is active and the deployed homepage returned expected content.'
                '''
            }
        }
    }
    post {
        success { echo 'SUCCESS: website deployment completed and verified.' }
        failure { echo 'FAILED: review the stage output above, correct the issue, and push again.' }
    }
}
