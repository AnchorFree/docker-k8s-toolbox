#!groovy​

pipeline {
    agent { label 'dockerd' }

    stages {
        stage('Build') {
            steps {
                dockerBuildTagPush(project: "aura-networking/docker-registry-public")
            }
        }
    }
}
