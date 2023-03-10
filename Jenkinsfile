/* groovylint-disable DuplicateMapLiteral, LineLength, NoDef, SpaceBeforeOpeningBrace */
/* groovylint-disable-next-line LineLength */
/* groovylint-disable CompileStatic, DuplicateStringLiteral, NestedBlockDepth, UnusedVariable, VariableName, VariableTypeRequired */
pipeline {
    agent any
    environment {
        def git_branch = 'master'
        def git_url = 'https://github.com/avidere/Docker-Deployment.git'

        def mvntest = 'mvn test '
        def mvnpackage = 'mvn clean install'
        def build_no = "${env.BUILD_NUMBER}"
        def sonar_cred = 'sonar'
        def code_analysis = 'mvn clean install sonar:sonar'
        def utest_url = 'target/surefire-reports/**/*.xml'

        def nex_cred = 'nexus'
        def grp_ID = 'example.demo'
        def nex_url = '18.180.61.139:8081'
        def nex_ver = 'nexus3'
        def proto = 'http'

        def remote_name = 'ubuntu'
        def remote_host = '18.183.130.147'
        def remote_user = 'devops'
        def remote_password = 'devops'
    }
    stages {
        stage('Git Checkout') {
            steps {
                script {
                    git branch: "${git_branch}", url: "${git_url}"
                    echo 'Git Checkout Completed'
                }
            }
        }
        /* groovylint-disable-next-line SpaceAfterClosingBrace */
        stage('Maven Build') {
            steps {
                sh "${env.mvnpackage}"
                echo 'Maven Build Completed'
            }
        }/*
        stage('Unit Testing and publishing reports') {
            steps {
                script {
                    sh "${env.mvntest}"
                    echo 'Unit Testing Completed'
                }
            }
            post {
                success {
                        junit "$utest_url"
                        jacoco()
                }
            }
        }
        stage('Static code analysis and Quality Gate Status') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: "${sonar_cred}") {
                        sh "${code_analysis}"
                    }
                    waitForQualityGate abortPipeline: true, credentialsId: "${sonar_cred}"
                }
            }
        } */
        stage('Upload Artifact to nexus repository') {
            steps {
                script {
                    def mavenpom = readMavenPom file: 'pom.xml'
                    def nex_repo = mavenpom.version.endsWith('SNAPSHOT') ? 'tomcat-SNAPSHOT' : 'tomact-Release'
                    nexusArtifactUploader artifacts: [
                    [
                        artifactId: 'helloworld',
                        classifier: '',
                        file: 'target/helloworld.war',
                        type: 'war'
                    ]
                ],
                    credentialsId: "${env.nex_cred}",
                    groupId: "${env.grp_ID}",
                    nexusUrl: "${env.nex_url}",
                    nexusVersion: "${env.nex_ver}",
                    protocol: "${env.proto}",
                    repository: 'tomcat-Release',
                    version: "${mavenpom.version}-${env.build_no}"
                    echo 'Artifact uploaded to nexus repository'
                    
                }
            }
        }/*
        stage('Transfer pom.xml file on remote server') {
            steps {
                script {
                    def remote = [:]
                    remote.name = "${remote_name}"
                    remote.host = "${remote_host}"
                    remote.user = "${remote_user}"
                    remote.password = "${remote_password}"
                    remote.allowAnyHosts = true
                    sshPut remote: remote, from: '/var/lib/jenkins/workspace/Tomcat-Project/pom.xml', into: '.'
                    sshPut remote: remote, from: '/var/lib/jenkins/workspace/Tomcat-Project/roles', into: '.'
                    sshPut remote: remote, from: '/var/lib/jenkins/workspace/Tomcat-Project/tomcat.yaml', into: '.'
                    sshPut remote: remote, from: '/var/lib/jenkins/workspace/Tomcat-Project/inventory', into: '.'
                }
            }
        } 

        stage('Execute Ansible Playbook on Ansible controller node') {
            steps {
                sshagent(['Ansible-Server']) {
                    sh 'ssh -o StrictHostKeyChecking=no -l devops 18.183.130.147 ansible-playbook tomcat.yaml -i inventory'
                }
            }
        }*/
        stage('Transfer file on EKS cluster'){
            steps{
                script{
                        def remote = [:]
                        remote.name = 'ubuntu'
                        remote.host = '172.31.22.228'
                        remote.user = 'dockeradmin'
                        remote.password = 'dockeradmin'
                        remote.allowAnyHosts = true
                        sshPut remote: remote, from: '/var/lib/jenkins/workspace/Deocker-EKS-Deployment/Deployment.yaml', into: '.'
                        sshPut remote: remote, from: '/var/lib/jenkins/workspace/Deocker-EKS-Deployment/service.yaml', into: '.'
                        sshPut remote: remote, from: '/var/lib/jenkins/workspace/Deocker-EKS-Deployment/Dockerfile', into: '.'
                }
            }
        }
        stage('Build Docker image and push on Docker hub'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'Docker_hub', passwordVariable: 'docker_pass', usernameVariable: 'docker_user')]) {
                script{
                    sshagent(['Docker-Server']) {
                        def mavenpom = readMavenPom file: 'pom.xml'
                        def artifactId= 'helloworld'
                        def tag = "${mavenpom.version}"
                    /* groovylint-disable-next-line GStringExpressionWithinString */
                        sh "ssh -o StrictHostKeyChecking=no -l dockeradmin 172.31.22.228 sed -i 's/tag/${mavenpom.version}-${env.build_no}/g' Deployment.yaml "
                        sh "ssh -o StrictHostKeyChecking=no -l dockeradmin 172.31.22.228 sudo cp Deployment.yaml service.yaml /home/ubuntu/"
                        sh "ssh -o StrictHostKeyChecking=no -l dockeradmin 172.31.22.228 docker build --build-arg artifact_id=${artifactId} --build-arg host_name=${env.nex_url} --build-arg version=${mavenpom.version} --build-arg build_no=${env.build_no} -t avinashdere99/tomcat:${mavenpom.version}-${env.build_no} ."
                        sh "ssh -o StrictHostKeyChecking=no -l dockeradmin 172.31.22.228 docker login -u $docker_user -p $docker_pass"
                        sh "ssh -o StrictHostKeyChecking=no -l dockeradmin 172.31.22.228 docker push avinashdere99/tomcat:${mavenpom.version}-${env.build_no}"
                        sh "ssh -o StrictHostKeyChecking=no -l dockeradmin 172.31.22.228 docker rmi avinashdere99/tomcat:${mavenpom.version}-${env.build_no}"
                    }
                   }
                }
            }
        }
        stage('Deploy Application on k8s Cluster'){
            steps{
                script{
                    sshagent(['Docker-Server']) {
                        def mavenpom = readMavenPom file: 'pom.xml'
                        def tag= "${mavenpom.version}"
                    /* groovylint-disable-next-line GStringExpressionWithinString */
                      //  sh "ssh -o StrictHostKeyChecking=no -l ubuntu 172.31.22.228 sudo sed 's/tag/${tag}/g' Deployment.yaml"
                        
                       sh "ssh -o StrictHostKeyChecking=no -l ubuntu 172.31.22.228 sudo kubectl apply -f Deployment.yaml"
                       sh "ssh -o StrictHostKeyChecking=no -l ubuntu 172.31.22.228 sudo kubectl apply -f service.yaml"
                       sh "ssh -o StrictHostKeyChecking=no -l ubuntu 172.31.22.228 sudo kubectl get all"
                    }

                }
            }
        }
    }
}

