// Scripted Pipeline. Configure the job as "Pipeline script from SCM".
node {
    try {
        stage('Checkout') {
            deleteDir()
            checkout scm
        }

        stage('Check uv') {
            sh '''
                command -v "${UV_BIN:-uv}"
                "${UV_BIN:-uv}" --version
            '''
        }

        stage('Setup') {
            sh 'bash scripts/setup.sh'
        }

        stage('Test') {
            sh 'bash scripts/test.sh'
        }

        stage('Build') {
            sh 'bash scripts/build.sh'
        }
    } finally {
        if (fileExists('reports/pytest.xml')) {
            junit testResults: 'reports/pytest.xml'
        }
        if (fileExists('dist')) {
            archiveArtifacts artifacts: 'dist/*', fingerprint: true
        }
    }
}
