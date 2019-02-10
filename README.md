# apiSampleJava

Assuming that we only have two environments production and staging. First of all branch permissions needs to be created, in order to protect branches from commits without Pull Request and other developers' approvals.

MultiBranch Pipeline Job has to be configured from Jenkins. Then webhook has to be configured from the Git Server, to trigger a Jenkins build.

As workflow, developers should push their branches, starting by feature/ if possible. All those branches will trigger a build in Jenkins, build the code, and test from the Dockerfile, then finally it will generate a Docker image only with the code.

In case the branch is `staging` or `master` will be pushed to the Docker registry, and deployed via Kubernetes. In case it is `master` branch the Jenkins build is going to be "Keep Build Forever" This branches are only be built when a PR is merged, after being built and reviewed by other developers.

In any cases the build result should be notify to the Git Server and Slack or any other similar message platform.

`mvn test` command was added to the Multistage Dockerfile to keep in that way. A different approach may be taken for a more complex testing. Integrate https://github.com/prometheus/client_java should be the next step to check what is going on in your environment. Also most of the code from Jenkinsfile should be moved to a shared-library. Sonarqube would be also added as part of this workflow for any branch.
