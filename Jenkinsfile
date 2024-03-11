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
                  echo "${version} !!! ${BUILD_NUMBER} !!!"
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
      stage('provision server') {
        environment {
          AWS_ACCESS_KEY_ID = credentials('jenkins-aws-access-key-id')
          AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
          // 更新default的env_prefix，语法是在前面加TF_VAR_
          TF_VAR_env_prefix = 'test'
        }
        steps {
            script {
                dir('terraform') {
                    sh "terraform init"
                    sh "terraform apply --auto-approve"
                    EC2_PUBLIC_IP = sh(
                        script: "terraform output ec2_public_ip",
                        returnStdout: true
                    ).trim()
                }
            }
          }
      }
      stage('deploy') {
          environment {
              DOCKER_CREDS = credentials('docker-hub-repo')
          }
          steps {
              script {
                  echo "waiting for EC2 server to initialize" 
                  sleep(time: 90, unit: "SECONDS") 

                  echo 'deploying docker image to EC2...'
                  echo "${EC2_PUBLIC_IP}"
                  //这里传参把IMAGE_NAME传给script了， script里的$1获取第一个传入的参数
                  def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
                  def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

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
            // withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-container-key', keyFileVariable: 'SSH_PRIVATE_KEY_FILE', passphraseVariable: 'SSH_PASSPHRASE', usernameVariable: 'SSH_USERNAME')]) {
             withCredentials([sshUserPrivateKey(credentialsId: 'github-access-key', keyFileVariable: 'SSH_PRIVATE_KEY_FILE', passphraseVariable: 'SSH_PASSPHRASE', usernameVariable: 'SSH_USERNAME')]) {
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
              sh 'git remote set-url origin git@github.com:MaMickey/java-jenkinsfile-sshagent.git'
              //正常commit并push
              sh 'git add .'
              sh 'git commit -m "ci:version bump"'
              // sh 'ssh -Tv git@github.com'
              sh 'git push -f origin HEAD:refs/heads/jenkins-with-terraform_jobs'
            } 
          }
        }
      }
  }
}
