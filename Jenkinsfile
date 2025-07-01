pipeline {
    agent any

    environment {
        BUILD_DIR = 'D:\\PxPointBuildScripts' // adjust if needed
    }

    stages {
        stage('Run PxPoint Quarterly Builds') {
            steps {
                script {
                    echo "🚀 Running run_all_builds.ps1 orchestrator"
                    powershell """
                        Set-Location ${BUILD_DIR}
                        .\\run_all_builds.ps1
                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ All builds completed successfully.'
        }
        failure {
            echo '❌ Build failed. Check logs for details.'
        }
    }
}
