🚀 Jenkins CI/CD Pipeline for Java Application

This project demonstrates a fully automated CI/CD pipeline using Jenkins.
The pipeline fetches code from GitHub, builds a Java application using Maven, performs static code quality analysis with SonarQube, stores build artifacts in Nexus Repository Manager, 
builds a Docker image and finally pushes it to DockerHub.

🏗️ CI/CD Workflow

Pipeline Stages:
Code Checkout ➝ From GitHub
Build & Packaging ➝ Using Maven
Code Quality Analysis ➝ SonarQube
Artifact Storage ➝ Nexus Repository
Docker Image Build
Push Docker Image ➝ DockerHub

📁 Project Structure
├── src
│   └── main / test ...
├── pom.xml
└── Dockerfile

=================================================
JENKINS-Installation:
=================================================
✅ 1. Launch Ubuntu EC2 Instance
1. Login to AWS Console → EC2 → Launch Instance
2. Choose Ubuntu Server 22.04 LTS (recommended)
3. Instance type: t2.medium/t3.medium
4. Key pair: Create or choose existing
5. Security Group Rules: Add the following

| Type           | Protocol | Port     | Source                          |
| -------------- | -------- | -------- | ------------------------------- |
| SSH            | TCP      | 22       | Your IP                         |
| HTTP           | TCP      | 80       | Anywhere                        |
| **Custom TCP** | TCP      | **8080** | Anywhere (Jenkins default port) |


6. Launch Instance
7. Once running, SSH into instance:

 "ssh -i <yourkey.pem> ubuntu@<EC2-Public-IP>
 
✅ 2. Update Ubuntu Packages
sudo apt update -y
sudo apt upgrade -y

✅ 3. Install Java and Maven on Ubuntu EC2

sudo apt install openjdk-17-jdk -y
sudo apt install maven -y

✅ 4. Get Java & Maven Installation Paths

readlink -f $(which java)
readlink -f $(which mvn)

✅ 5. Install Jenkins

curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

✅ 6. Start and Enable Jenkins Service

sudo systemctl start jenkins    
sudo systemctl enable jenkins
sudo systemctl status jenkins

✅ 7. Open Browser & Access Jenkins

http://<EC2-Public-IP>:8080

✅ 8. Get Initial Admin Password

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

✅ 9. Install Plugins

Choose:

✔ Install Suggested Plugins (recommended)
Plugins installation may take 3–5 minutes.

✅ 10. Create First Admin User



🎯 Now Configure Java & Maven Inside Jenkins

Step 1 — Go to Jenkins UI
Manage Jenkins → Tools
Step 2 — Under "JDK Installations"
Click Add JDK
Uncheck "Install automatically"
Add:
Name: jdk
JAVA_HOME: /usr/lib/jvm/java-17-openjdk-amd64

Click Save

Step 1 — Manage Jenkins → Tools
Scroll to Maven Installations
Click Add Maven
Enter:
Name: maven
Uncheck Install Automatically
MAVEN_HOME: /usr/share/maven
Click Save

🧪 If Jenkins Cannot Detect Maven/Java
sudo nano /etc/profile

Add below data:

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export M2_HOME=/usr/share/maven
export MAVEN_HOME=/usr/share/maven
export PATH=$M2_HOME/bin:$JAVA_HOME/bin:$PATH

save & apply:
source /etc/profile

Restart Jenkins:
sudo systemctl restart jenkins

============================================
GITHUB :
============================================
🔑 Add GitHub Credentials in Jenkins (Required for Code Checkout)

To allow Jenkins to fetch code from your GitHub repository, follow these steps:

Go to Jenkins Dashboard
➡️ Manage Jenkins → Credentials → System → Global credentials (unrestricted)

Click Add Credentials
Select:
Kind: Username with password (or Secret text if using a personal access token)
Username: Your GitHub username
Password/Token:
Recommended: Use a GitHub Personal Access Token

Token must include permissions:
✔ repo (full control of private/public repo)
✔ workflow (if GitHub Actions also used)
Set:
ID: github-cred
Description: GitHub credentials for Jenkins SCM
Click Create

===========================================
DOCKER INSTALL AND CONFIG IN JENKINS:
===========================================
🚀 PART 1 — Install Docker on Ubuntu EC2 Instance

Step 1: Update packages
sudo apt update -y
sudo apt upgrade -y

Step-2: Install Docker using docker.io
sudo apt install docker.io -y

Step-3: Enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

Step-4: Check Docker version
docker --version

✅ PART 2 - Add ubuntu User & Jenkins User to Docker Group

Docker commands need permissions. We must add Jenkins to the docker group.

Step-1: Add your default user
sudo usermod -aG docker $USER

Step-2: Add Jenkins user
sudo usermod -aG docker jenkins

Step-3: Restart Jenkins & Docker
sudo systemctl restart docker
sudo systemctl restart jenkins

Step-4: Very important – give proper Docker socket permissions
sudo chmod 666 /var/run/docker.sock

✅ PART 3 - Verify Jenkins Can Use Docker

Login into Jenkins server:

Run as Jenkins user:
sudo su - jenkins
docker ps

If you see output (even empty list), Jenkins can use Docker successfully.

------------------------------------------------------
1. Login to Docker Hub

Go to:
🔗 https://hub.docker.com/
Login with your username & password.
2. Go to Account Settings
Top-right corner → Click your profile icon → Account Settings
3. Open “Security” Tab
Left side menu → click Security
You will see a section called:
👉 Access Tokens
4. Create a New Access Token
Click:
🟦 Create Access Token

Then:
Token description:
Example: jenkins-cicd
Access type:
Choose: Read, Write, Delete (required for pushing images)
Click Create.

5. Copy the Access Token

VERY IMPORTANT:

🔴 Copy the token immediately. You cannot view it again.
Keep it safe. This is what you will add in Jenkins.


🔐 Use in Jenkins Credentials
Now go to Jenkins:
Manage Jenkins → Credentials → System → Global → Add Credentials
Set:
Kind: Username with password
Username: Your Docker Hub Username
Password: Paste the Access Token
ID: dockerhub-cred (recommended)
Description: Jenkins Docker Hub Token
Click Save

=================================================================
NEXUS ARTIFACTORY 
=================================================================
NEXUS INSTALLATION:
-------------------
Step 1: Update and Upgrade Packages
sudo apt update && sudo apt upgrade -y

✔ Updates the package list
✔ Installs the latest updates
Ensures your server is up-to-date before installing Nexus.

Step 2: Install Java 
sudo apt install openjdk-11-jdk -y
java --version

Nexus 3 requires Java 8 or Java 11.
You installed Java 11 JDK.

Step 3: Create a Dedicated Nexus User
sudo adduser --disabled-password --gecos "" nexus
sudo usermod -aG sudo nexus

✔ Creates a new user nexus
✔ This user will run the Nexus application, improving security
✔ The user has NO password, meaning login is disabled — safer
✔ Gives sudo permission (optional but okay)

Step 6: Install Nexus 
cd /opt
sudo wget https://download.sonatype.com/nexus/3/nexus-3.70.4-02-java8-unix.tar.gz
sudo tar -xvzf nexus-3.70.4-02-java8-unix.tar.gz
sudo mv /opt/nexus-3.70.4-02 /opt/nexus
sudo chown -R nexus:nexus /opt/nexus
sudo mkdir -p /opt/sonatype-work
sudo chown -R nexus:nexus /opt/sonatype-work


Meaning:
/opt is the standard directory for installing 3rd-party software.
Downloads the Nexus installation package.
✔ Extracts the Nexus files in /opt
✔ Creates a directory like:
/opt/nexus-3.70.4-02
✔ Rename for simplicity
/opt/nexus is easier to work with.
✔ Change ownership
Nexus must run as nexus user, not root.
✔ Create ‘sonatype-work’ directory
This directory stores:
Repositories
Configuration
Logs
Components

This is the heart of Nexus storage.

Step 5 (additional): Configure Nexus to run as nexus user
sudo nano /opt/nexus/bin/nexus.rc
Add:
run_as_user="nexus"

✔ This tells Nexus to start using the nexus user, not root.
✔ Mandatory for production.

Step 6: Create Systemd Service
You create a service file:
sudo nano /etc/systemd/system/nexus.service

Paste:

[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target

What this means:
🔹 Unit section
Runs after networking is ready
Gives name & description
🔹 Service section
User=nexus: Run as nexus user
LimitNOFILE=65536: Increase file limit (Nexus needs many open files)
ExecStart: Command to start Nexus
ExecStop: Command to stop Nexus
Restart=on-abort: Restart if it crashes
🔹 Install section
Enables the service to run automatically at boot

Step 7: Enable and Start Nexus

sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
sudo systemctl status nexus


🌐 Now you can access Nexus
Open browser:
http://<server-public-ip>:8081
Default credentials:
username: admin
password: (found in /opt/sonatype-work/nexus3/admin.password)

NEXUS CONFIGURATION :
---------------------
✅ Step 1: Create Repositories in Nexus
You need two important Maven repositories for real-time CI/CD:
Hosted Repo (for storing your artifacts)
Used by Jenkins to upload .jar/.war artifacts.
Create it:

Login → Go to Settings (gear icon)
Repositories → Create Repository
Select → maven2 (hosted)
Configure:
Name: maven-releases
Version policy: Release
Deployment policy: Allow redeploy
Save.

Repeat again for snapshots:
Hosted Repo – Snapshots
Name: maven-snapshots
Version policy: Snapshot
Deployment policy: Allow redeploy
Save.

✅ Step 2: Generate Nexus Credentials for Jenkins

Jenkins will require username & password to upload artifacts.

Create a Nexus user:
Settings → Security → Users → Create user
Name: jenkins
Password: (choose)
Roles → Give:
nx-admin (or repo-specific roles)
Save.

✅ STEP 3: Add Credential in Jenkins (Nexus user)
Go to Jenkins:
Manage Jenkins → Manage Credentials
Choose global credentials → Add new credential:
Kind: Username with password
ID: nexus-credentials
Username: jenkins
Password: <your-password>

Description: Nexus Credentials

✔ This credential will be used inside Jenkinsfile or Maven settings.

✅ Step 4: Configure Maven on Jenkins (settings.xml)

Jenkins needs a custom settings.xml to authenticate with Nexus.

Create settings.xml on Jenkins server
sudo cd /var/lib/jenkins/.m2
sudo touch settings.xml
sudo nano /var/jenkins_home/.m2/settings.xml

Paste:

<settings>
  <servers>
    <server>
      <id>nexus-releases</id>
      <username>admin</username>
      <password>admin123</password>
    </server>
    <server>
      <id>nexus-snapshots</id>
      <username>admin</username>
      <password>admin123</password>
    </server>
  </servers>
</settings>

Restart Jenkins:

sudo systemctl restart jenkins


✅ STEP 5: Configure your Project’s pom.xml

Deploying artifacts to Nexus requires this section:
<distributionManagement>
    <repository>
        <id>nexus-releases</id>
        <url>http://<NEXUS-IP>:8081/repository/maven-releases/</url>
    </repository>

    <snapshotRepository>
        <id>nexus-snapshots</id>
        <url>http://<NEXUS-IP>:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>


✔ Release versions go to maven-releases
✔ SNAPSHOT versions go to maven-snapshots

NOTE:
settings.xml → <server><id>...</id></server>
pom.xml      → <distributionManagement><repository><id>...</id>

Ensure that the <id> value used in the pom.xml distributionManagement section exactly matches the <id> defined in the settings.xml servers section, 
as Maven relies on this match to apply the correct credentials during artifact deployment.


=====================================================
SONARQUBE:
=====================================================
SONARQUBE INSTALLATION:
------------------------------------------------------
Step 1: Update and upgrade server packages

sudo apt update && sudo apt upgrade -y

Step 2: Install Docker

sudo apt install docker.io -y

Installs the docker.io package from Ubuntu repository

Step 3: Start Docker service

sudo systemctl start docker
sudo systemctl enable docker
sudo docker --version

Step 4: Pull SonarQube Docker image

sudo docker pull sonarqube:community

Downloads the official SonarQube Community Edition image from Docker Hub

Step 5:List downloaded images

sudo docker images

Step 6: Run SonarQube Container

sudo docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=sonar \
  sonarqube:community


Let’s break this down:
✔ docker run -d
-d → Run container in background (detached mode)
✔ --name sonarqube
Gives the container a name
Useful for logs, stopping, starting
Example: docker logs sonarqube
✔ -p 9000:9000
Maps the container port 9000 → host port 9000
So you can access SonarQube UI at:
👉 http://<your-server-ip>:9000
✔ Environment variables
-e SONAR_JDBC_USERNAME=sonar
-e SONAR_JDBC_PASSWORD=sonar
These are for DB credentials
⚠️ But note:
The community SonarQube image has its own embedded DB
If you are not attaching an external PostgreSQL DB
These env variables are ignored
SonarQube will run using built-in database
So this works fine — no error — but DB is internal.

Step 7: Access SonarQube UI
Open in browser:
👉 http://<EC2-PUBLIC-IP>:9000
Default login:
Username: admin
Password: admin
(You will be asked to reset password)


Step 8: Create Sonar Token in UI

Open SonarQube:
👉 http://<sonar-ip>:9000
Login:
admin / admin
Go to:
My Account → Security → Generate Token → Name: sonar-token
Copy the token.

-----------------------------------------------------------
SONARQUBE CONFIGURATION:
-----------------------------------------------------------
PART 1 — Add SonarQube Server in Jenkins

Step 1: Login to Jenkins
	Manage Jenkins → Configure System

Step 2: Scroll to “SonarQube Servers” section
	Click Add SonarQube.

Step 3: Fill SonarQube Details

Field	Value
Name			:	sonar (or any name)
Server URL		: http://<sonarqube-ip>:9000
Server Authentication Token : 	Use token from SonarQube(sonar-token)

Step 4: Add the Token in Jenkins Credentials

Jenkins → Manage Jenkins → Credentials → Global → Add Credential
Select:
Kind: Secret Text
Secret: paste sonar token
ID: sonar-token
Description: sonar token
Back in Configure System → select this credential.

✔ SonarQube server is now integrated with Jenkins

✅ PART 2 — Install SonarQube Scanner in Jenkins

Step 1: Manage Jenkins → Manage Plugins
Go to Available Plugins and install:
SonarQube Scanner
Pipeline: SonarQube
Pipeline Utility Steps
Restart Jenkins (safe restart recommended).

Step 2: Configure Scanner
Go to:
Manage Jenkins → Global Tool Configuration
Scroll to:
SonarQube Scanner
Click Add SonarQube Scanner
Fill:
Field	Value
Name:	sonar-scanner
Install automatically:	 Enable
This allows Jenkins to download the scanner itself.

✔ SonarQube Scanner is now installed.

📌 Explanation of Important Parts
withSonarQubeEnv('sonar')
'sonar' = name you configured in Jenkins → SonarQube servers
Injects:
sonar host URL
sonar auth token
environment variables


==================================================================
🌐 Allow Required Ports (Firewall / Security Group)

Ensure the following ports are open on your server so all CI/CD tools can communicate:

| Type           | Protocol | Port     | Source                        |
| -------------- | -------- | -------- | ----------------------------- |
| SSH            | TCP      | 22       | Your IP                       |
| HTTP           | TCP      | 80       | Anywhere                      |
| **Custom TCP** | TCP      | **8080** | Anywhere *(Jenkins)*          |
| **Custom TCP** | TCP      | **8081** | Anywhere *(Nexus Repository)* |
| **Custom TCP** | TCP      | **9000** | Anywhere *(SonarQube)*        |



========================================
🧩 Jenkins Pipeline Script (Jenkinsfile)
========================================

pipeline {
    agent any

    tools {
        jdk 'java'
        maven 'maven'
    }

    environment {
        GITHUB_CREDENTIALS = 'github-pat'
        DOCKERHUB_CREDENTIALS = 'dockerhub-cred'
        NEXUS_CREDENTIALS = 'nexus-cred'
        IMAGE_NAME = 'sivasaikrishna1809/jenkins-ci'
    }

    options {
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/sivasaikrishna1809/jenkins-ci.git',
                    credentialsId: "${GITHUB_CREDENTIALS}"
                echo '✅ Checkout Code stage done'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn -B clean package -DskipTests'
                echo '✅ Build with Maven stage done'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar -DskipTests'
                    sh 'mvn sonar:sonar -Dsonar.login=sonar-token1'
                }
                echo '✅ SonarQube Analysis stage done'
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: "${NEXUS_CREDENTIALS}",
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )]) {
                        sh """
                            mvn deploy \
                              -DskipTests \
                              -Dnexus.username=$NEXUS_USER \
                              -Dnexus.password=$NEXUS_PASS
                        """
                    }
                }
                echo '✅ Upload Artifact to Nexus stage done'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def commit = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
                    def tag = "${env.BUILD_NUMBER}-${commit}"

                    sh "docker build -t ${IMAGE_NAME}:${tag} ."
                    sh "docker tag ${IMAGE_NAME}:${tag} ${IMAGE_NAME}:latest"

                    env.IMAGE_TAG = tag
                }
                echo '✅ Build Docker Image stage done'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: "${DOCKERHUB_CREDENTIALS}",
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${IMAGE_NAME}:${IMAGE_TAG}
                            docker push ${IMAGE_NAME}:latest
                            docker logout
                        """
                    }
                }
                echo '✅ Push to Docker Hub stage done'
            }
        }

        stage('Cleanup') {
            steps {
                sh """
                    docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
                    docker rmi ${IMAGE_NAME}:latest || true
                """
                echo '✅ Cleanup stage done'
            }
        }
    }

    post {
        success {
            echo "✅ Build #${BUILD_NUMBER} succeeded. Artifact uploaded to Nexus, Docker image pushed, and SonarQube quality gate passed."
        }
        failure {
            echo "❌ Build failed or SonarQube quality gate failed."
        }
    }
}


----------------------------------------------------------
Note:
🔄 Replace repo details, image names, and credentials IDs with your actual configuration.

----------------------------------------------------------



