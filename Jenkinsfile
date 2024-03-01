#!/usr/bin/env groovy

// library identifier: 'jenkins-shared-library@master', retriever: modernSCM(
//     [$class: 'GitSCMSource',
//      remote: 'https://gitlab.com/nanuchi/jenkins-shared-library.git',
//      credentialsId: 'gitlab-credentials'
//     ]
// )

// library identifier: 'jenkins-shared-library@master', retriever: modernSCM(
//     [$class: 'GitSCMSource',
//      //这个位置之前连接GitHub和jenkins时，用https不行，改用ssh，所以这个应该不work
//      remote: 'https://github.com/MaMickey/jenkins-shared-library.git',
//      //这个是存在jenkin的属于连接github的credential
//      credentialsId: 'github-repo'
//     ]
// )
//这里我已经将library在Jenkins里引用了
@Library('jenkins-shared-libraries')_

pipeline {
    agent any
    tools {
        maven 'maven-3.8'
    }
    //和之前的env.IMAGE_NAME = "$version-$BUILD_NUMBER" 写法不同，给environment一个变量，并赋值
    environment {
        IMAGE_NAME = 'mickyma22/my-repo:java-maven-1.0'
    }
    stages {
      stage("increment version") {
          steps {
            script {
              echo 'incrementing version...'
              sh 'mvn build-helper:parse-version versions:set \
                  -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                  versions:commit'
                  def matcher = readFile('pom.xml') =~'<version>(.+)</version>'
                  def version = matcher[0][1]
                  //我们想让版本号+build的每次号码叫image name
                  env.IMAGE_NAME = "$version-$BUILD_NUMBER"
            }
        }
      }
        stage('build app') {
            steps {
               script {
                  echo 'building application jar...'
                  buildJar()
               }
            }
        }
        stage('build image') {
            steps {
                script {
                   echo 'building docker image...'
                   //这里用image_name
                   buildImage(env.IMAGE_NAME)
                }
            }
        }
        stage('push image') {
          steps {
            script {
              dockerLogin()
              dockerPush(env.IMAGE_NAME)

            }
          }
        }
        stage('deploy') {
            steps {
                script {
                   echo 'deploying docker image to EC2...'
                  //这里传参把IMAGE_NAME传给script了， script里的$1获取第一个传入的参数
                   def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                   def ec2Instance = "ec2-user@13.211.190.16"

                   sshagent(['ec2-server-key']) {
                       sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
                       sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                       sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                   }
                }
            }
        }
        stage("commit version update") {
          steps {
            script {
              //改用ssh
              //withCredentials([usernamePassword(credentialsId: 'github-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
              
              //这里重新设置了jenkins container里的一套key,并添加到github
              withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-container-key', keyFileVariable: 'SSH_PRIVATE_KEY_FILE', passphraseVariable: 'SSH_PASSPHRASE', usernameVariable: 'SSH_USERNAME')]) {
                //全局设置往上push的名字和邮箱，只需设置1次，第一次设了就可以
                sh 'git config --global user.email "jenkins@example.com"'
                sh 'git config --global user.name "Jenkins"'
                //查看设置和状态
                sh 'git status'
                sh 'git branch'
                sh 'git config --list'
                //将remote设置为指定url路径，那么后面push的时候就知道origin是什么了
                //set the Git remote URL using environment variables for the GitHub username and password
                //github又弃用了， 改用ssh吧
                // sh "git remote set-url origin https://${USER}:${PASS}@github.com/MaMickey/java-maven-app-multi-branch.git"
                sh 'git remote set-url origin git@github.com:MaMickey/java-jenkinsfile-sshagent.git'
                //正常commit并push
                sh 'git add .'
                sh 'git commit -m "ci:version bump"'
                // sh 'ssh -Tv git@github.com'
                sh 'git push origin HEAD:refs/heads/jenkins_jobs'
              } 
            }
          }
        }
    }
}
