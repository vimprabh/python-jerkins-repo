// Scripted Pipeline. Configure the job as "Pipeline script from SCM".
properties([
    disableConcurrentBuilds(),
    parameters([
        string(name: 'DOCKERHUB_IMAGE', defaultValue: 'your-dockerhub-username/jenkins-uv-starter',
               description: 'Docker Hub namespace/repository, in lowercase'),
        string(name: 'DOCKERHUB_CREDENTIALS_ID', defaultValue: 'dockerhub-credentials',
               description: 'Jenkins username/password credential: username and Docker Hub access token'),
        choice(name: 'DOCKER_PLATFORM', choices: ['native', 'linux/amd64', 'linux/arm64'],
               description: 'native uses the agent architecture; choose the platform needed for deployment')
    ])
])

node {
    try {
        stage('Checkout') {
            deleteDir()
            checkout scm
        }

        stage('Check tools') {
            if (!params.DOCKERHUB_IMAGE || params.DOCKERHUB_IMAGE.startsWith('your-dockerhub-username/')) {
                error('Use Build with Parameters and set DOCKERHUB_IMAGE to your Docker Hub namespace/repository.')
            }
            env.DOCKER_IMAGE = params.DOCKERHUB_IMAGE.trim()
            env.DOCKER_PLATFORM = params.DOCKER_PLATFORM == 'native' ? '' : params.DOCKER_PLATFORM
            def commit = sh(script: 'git rev-parse --short=12 HEAD', returnStdout: true).trim()
            env.IMAGE_TAG = "build-${env.BUILD_NUMBER}-${commit}"
            sh '''
                command -v "${UV_BIN:-uv}"
                "${UV_BIN:-uv}" --version
                "${DOCKER_BIN:-docker}" version
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

        stage('Docker build') {
            sh 'bash scripts/docker-build.sh'
        }

        stage('Docker test') {
            sh 'bash scripts/docker-test.sh'
        }

        stage('Push to Docker Hub') {
            withCredentials([usernamePassword(
                credentialsId: params.DOCKERHUB_CREDENTIALS_ID,
                usernameVariable: 'DOCKERHUB_USERNAME',
                passwordVariable: 'DOCKERHUB_TOKEN'
            )]) {
                sh 'bash scripts/docker-push.sh'
            }
            echo "Published docker.io/${env.DOCKER_IMAGE}:${env.IMAGE_TAG}"
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
