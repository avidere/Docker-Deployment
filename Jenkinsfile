/* groovylint-disable DuplicateMapLiteral, LineLength, NoDef, SpaceBeforeOpeningBrace */
/* groovylint-disable-next-line LineLength */
/* groovylint-disable CompileStatic, DuplicateStringLiteral, NestedBlockDepth, UnusedVariable, VariableName, VariableTypeRequired */
pipeline {
    agent any
    environment {
        def git_branch = 'master'
        def git_url = 'https://github.com/avidere/TomcatMavenApp.git'

        def mvntest = 'mvn test '
        def mvnpackage = 'mvn clean install'

        def sonar_cred = 'sonar'
        def code_analysis = 'mvn clean install sonar:sonar'
        def utest_url = 'target/surefire-reports/**/*.xml'

        def nex_cred = 'nexus'
        def grp_ID = 'example.demo'
        def nex_url = '172.31.28.226:8081'
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
                    version: "${mavenpom.version}"
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
        stage('Build Docker image and run container'){
            steps{
                script{
                    def mavenpom = readMavenPom file: 'pom.xml'
                    def artifactId= 'helloworld'
                    def version = "${mavenpom.version}"

                    sshagent(['Docker-Server']) {
                    /* groovylint-disable-next-line GStringExpressionWithinString */
                        sh 'ssh -o StrictHostKeyChecking=no -l dockeradmin 43.207.81.86 docker build --build-args artifact_id=helloworld --build-args version=1.0 -t tomcat:v3 .'
                    }

                }
            }
        }
    }
}

