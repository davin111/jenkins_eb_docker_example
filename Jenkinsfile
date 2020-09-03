// Define variable
def ecrName = ""
def repoName = ""
def bucketName = ""
def environmentName = ""
def applicationName = ""
def applicationPath = "."
def phase = ""

pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                sh "rm -f ${applicationPath}/.docker/version.zip"
                sh "bash ${applicationPath}/.docker/generate-dockerrun.sh ${applicationName} ${BUILD_TIMESTAMP} ${phase}"
                sh "bash ${applicationPath}/.docker/generate-version.sh"
                zip zipFile: "${applicationPath}/.docker/version.zip", dir: "${applicationPath}/.docker/dist", glob: "**/*"
                sh "npm install"
                sh "aws ecr describe-repositories --repository-names ${repoName}/${applicationName} || aws ecr create-repository --repository-name ${repoName}/${applicationName}"
                sh "docker build -t ${applicationName}:${BUILD_TIMESTAMP} . -f ${applicationPath}/.docker/Dockerfile"
                sh "docker build -t ${applicationName}:latest . -f ${applicationPath}/.docker/Dockerfile"
                sh "docker tag ${applicationName}:latest ${ecrName}/${repoName}/${applicationName}:latest"
                sh "docker tag ${applicationName}:${BUILD_TIMESTAMP} ${ecrName}/${repoName}/${applicationName}:${BUILD_TIMESTAMP}"
                sh "aws ecr get-login --region ap-northeast-2"
                sh "docker push ${ecrName}/${repoName}/${applicationName}:${BUILD_TIMESTAMP}"
                sh "docker push ${ecrName}/${repoName}/${applicationName}:latest"
                sh "aws ecr describe-repositories --repository-names ${repoName}/${applicationName}-nginx || aws ecr create-repository --repository-name ${repoName}/${applicationName}-nginx"
                sh "docker build -t ${applicationName}-nginx:${BUILD_TIMESTAMP} . -f ${applicationPath}/.docker/Dockerfile.nginx"
                sh "docker build -t ${applicationName}-nginx:latest . -f ${applicationPath}/.docker/Dockerfile.nginx"
                sh "docker tag ${applicationName}-nginx:latest ${ecrName}/${repoName}/${applicationName}-nginx:latest"
                sh "docker tag ${applicationName}-nginx:${BUILD_TIMESTAMP} ${ecrName}/${repoName}/${applicationName}-nginx:${BUILD_TIMESTAMP}"
                sh "docker push ${ecrName}/${repoName}/${applicationName}-nginx:${BUILD_TIMESTAMP}"
                sh "docker push ${ecrName}/${repoName}/${applicationName}-nginx:latest"
            }
        }

        stage('upload') {
            steps {
                echo 'Uploading'
                sh "mv ./.docker/version.zip ${applicationName}-${phase}.zip"
                sh "aws s3 cp ${applicationName}-${phase}.zip s3://${bucketName}/${applicationName}/${JOB_NAME}-${BUILD_TIMESTAMP}.zip \
                    --acl public-read-write \
                    --region ap-northeast-2"
            }
        }

        stage('deploy') {
            steps {
                echo 'Deploying'
                sh "aws elasticbeanstalk create-application-version \
                    --region ap-northeast-2 \
                    --application-name ${applicationName} \
                    --version-label ${JOB_NAME}-${BUILD_TIMESTAMP} \
                    --description ${BUILD_TAG} \
                    --source-bundle S3Bucket='${bucketName}',S3Key='${applicationName}/${JOB_NAME}-${BUILD_TIMESTAMP}.zip'"
                sh "aws elasticbeanstalk update-environment \
                    --region ap-northeast-2 \
                    --environment-name ${applicationName}-${environmentName} \
                    --version-label ${JOB_NAME}-${BUILD_TIMESTAMP}"
            }
        }
    }
}

