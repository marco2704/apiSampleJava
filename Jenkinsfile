

// Most of this code should be moved to a shared-library 

String dockerRegistry = 'registry.adidas.com'
String dockerRegistryCredentialsId = 'dockerRegistryCredentialsId'
String dockerImageName = dockerRegistry
String APP_VERSION = "1.0-SNAPSHOT"

Map deployableBranches = [
    development: "development",
    staging: 'staging',
    master: 'production'
]

nodeWithTimeout('linux && docker') {
  try {
    stage('Workspace Cleanup') {
      cleanWs() // This ensures a clean workspaces
    }

    stage('Checkout') {
      def scmVars = checkout scm
      env.GIT_COMMIT = scmVars.GIT_COMMIT // env.GIT_COMMIT is missing when the job is re-build or replayed.
    }

    // It will not depend on the slave setup, it will only require Docker
    docker.image('maven:3.5-jdk-8-alpine').inside('-v $HOME/.m2:/root/.m2') {
      stage('Build') {
        sh 'mvn --batch-mode -DskipTests -Drevision=1.0-SNAPSHOT clean package' 
      }

      stage('Test') {
        sh 'mvn test'
      }
    }

    stage('Sonar Scanner') {
         withSonarQubeEnv 'Sonarqube7 Staging', {
            final String scannerHome = tool 'SonarQube 2.3'
            sh "${scannerHome}/bin/sonar-runner -Dsonar.host.url=${env.SONAR_HOST_URL} -Dsonar.branch=${env.BRANCH_NAME}"
        }
    }

    if (deployableBranches[env.BRANCH_NAME]) {
      try {
        String dockerImageTag = env.GIT_COMMIT[[0..6]]
        dockerImageName = "${dockerRegistry}/api-sample-java:${dockerImageTag}-${env.BUILD_NUMBER}"

        withDockerRegistry([credentialsId: dockerRegistryCredentialsId, url:"https://${dockerRegistry}"]) { 
          stage('Build Docker Image') {
            sh "docker build --no-cache --rm --pull -t ${dockerImageName} --build-arg REVISION=${APP_VERSION}  ."
          }

          stage('Publish Docker Image') {
            sh "docker push ${dockerImageName}"
          }
        }
      } finally {
        sh "docker rmi ${dockerImageName}"
      }

      stage('Deployment') {
        // TODO: K8 Deployment
      }
    }

    if (deployableBranches[env.BRANCH_NAME] == 'production') {
      stage('Keep Build Forever') {
        currentBuild.keepLog = true
      }
    }

    currentBuild.result = 'SUCCESS' // currentBuild.result is null at this point
  } catch(exception) {
    currentBuild.result = 'FAILURE' // currentBuild.result is still null at this point
    throw exception
  } finally {
    stage ('Notify build result') {
      // TODO: Update commit status with the build result. Bitbucket, GitHub, Gitlab, etc.
      // It allows to check the build result of each commit from the Git Server. A must-have for PR.
      // TODO: Notify to Slack, Microsoft Teams, etc.
    }
  }
}

// Using timout step is a good practice that avoids unnecessary stuck builds
void nodeWithTimeout(String label, def body) {
    timeout(time: 60, unit: 'MINUTES') {
        node(label) {
            body.call()
        }
    }
}
