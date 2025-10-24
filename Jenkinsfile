pipeline {
  agent any
  environment {
    DOCKER_IMG = "gs-spring-boot1:1.0"
    CONTAINER  = "gs-spring-boot1"
  }
  options { timestamps(); disableConcurrentBuilds() }

  stages {
    stage('Checkout') {
      steps {
        // If your job is "Pipeline script from SCM", you can remove this 'git' step.
        git url: 'https://github.com/angelovskid1/gs-spring-boot1.git', branch: 'main'
      }
    }
    stage('Build fat JAR') {
      steps {
        sh '''
          set -e
          chmod +x mvnw gradlew 2>/dev/null || true
          if [ -f "pom.xml" ]; then
            if [ -x "./mvnw" ]; then ./mvnw clean package -DskipTests; else mvn clean package -DskipTests; fi
          elif [ -f "build.gradle" ] || [ -f "settings.gradle" ]; then
            ./gradlew clean bootJar -x test
          else
            echo "No pom.xml or build.gradle found"; exit 1
          fi
        '''
      }
      post { success { archiveArtifacts artifacts: 'target/*.jar, build/libs/*.jar', fingerprint: true } }
    }
    stage('Build Docker image') {
      steps { sh 'docker build -t ${DOCKER_IMG} .' }
    }
    stage('Run container on 8081') {
      steps {
        sh 'docker rm -f ${CONTAINER} || true'
        sh 'docker run -d -p 8081:8080 --name ${CONTAINER} ${DOCKER_IMG}'
      }
    }
  }
  post { always { sh 'docker ps --format "table {{.Names}}\\t{{.Image}}\\t{{.Ports}}" || true' } }
}
