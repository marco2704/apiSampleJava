

// Most of this code should be moved to a shared-library 

String dockerRegistry = 'registry.adidas.com'
String dockerRegistryCredentials = 'dockerRegistryCredentialsId'
String dockerImageName = dockerRegistry

Map deployableBranches = [
    master: 'production',
    staging: 'staging',
]

nodeWithTimeout('linux && docker') {
  try {
    stage('Workspace Cleanup') {
      cleanWs()
      // This ensures a clean workspaces
    }

    stage('Checkout') {
      def scmVars = checkout scm
      env.GIT_COMMIT = scmVars.GIT_COMMIT 
      // env.GIT_COMMIT is missing when the job is re-build or replayed.
    }

    stage('Setup') {
      String dockerImageTag = env.GIT_COMMIT[[0..6]]
      dockerImageName = "${dockerRegistry}/api-sample-java:${dockerImageTag}-${env.BUILD_NUMBER}" 
    }

    try {
      withDockerRegistry([credentialsId: dockerRegistryCredentials, url:"https://${dockerRegistry}"]) { 
        stage('Build Docker Image') {
          sh "docker build --no-cache --rm --pull -t ${dockerImageName} ."
        }

        if (deployableBranches[env.BRANCH_NAME]) {
          stage('Publish Docker Image') {
            sh "docker push ${dockerImageName}"
          }
        }
      }
    } finally {
      sh "docker rmi ${dockerImageName}"
    }

    if (deployableBranches[env.BRANCH_NAME]) {
      stage('Deployment') {
        // TODO: K8 Deployment
      }
    }

    if (deployableBranches[env.BRANCH_NAME] && deployableBranches[env.BRANCH_NAME] == 'production') {
      stage('Keep Build Forever') {
        currentBuild.keepLog = true
      }
    }

    currentBuild.result = 'SUCCESS'
    // currentBuild.result is null at this point
  } catch(exception) {
    currentBuild.result = 'FAILURE'
    // currentBuild.result is still null at this point
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
