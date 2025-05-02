# Implementing Blue/Green Deployments with AWS CI/CD Pipelines on Amazon Elastic Container Service
![Diagram](./media/diagram.png)

CI/CD Pipeline using AWS Services to Deploy Application on Elastic Container Service

This article will deploy a simple HTML web page on the [AWS Elastic Container Service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html). 
Using the [AWS CodeDeploy](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html), 
[AWS CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html), 
and [AWS CodePipeline](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html) services we will configure an end-to-end continuous deployment (CD) pipeline to build and store container images, and then perform a blue/green deployment. 
Using AWS DevOps tools we will:

1.  Configure a Github repository as an input artifact source for the **AWS CodePipeline**.
2.  **Using AWS CodeBuild**, build Docker container images and store them in the Amazon Elastic Container Registry (AWS ECR).
3.  **Using AWS CodeDeploy**, deploy the web application on AWS ECS using blue/green deployments to minimize application interruptions and provide a rollback in case of failure.
4.  Use **AWS CodePipeline** to orchestrate the CI/CD workflow.

That being said I assume that you have the following knowledge:

*   Basic understanding of AWS Services and how to navigate through the AWS Console.
*   Basic coding and scripting knowledge.

**Table of Contents:**
- Initial Environment 
- Review the Application Artifact on GitHub Repository 
  - Step 1: Review the source code on GitHub 
  - Step 2: Create the elastic container registry to host the docker image 
  - Step 3: Modify the BuildSpec file to contain the AWS ECR repository URI
- Create the Continuous Delivery Pipeline to Build your Application Image 
  - Step 1: Create a pipeline using AWS CodePipeline 
  - Step 2: Add stage for the application source code 
  - Step 3: Add stage for building application code 
  - Step 4: Pipeline execution failure resolution
- Create the ECS Cluster Components Manually to Support the Application Deployment
  - Step 1: Create AWS ECS cluster and ECS task definition 
  - Step 2: Create the AWS application load balancer 
  - Step 3: Create the AWS ECS service with AWS CodeDeploy handler 
  - Step 4: Create the taskdef.json file and push changes to the source code repository
- Configure the Deploy Stage in the Pipeline 
- Check the correct functioning of the application 
- Configure the Blue/Green Deployment using the Deploy Stage 
  - Step 1: Review the CodeDeploy application and deployment group 
  - Step 2: Add the deploy stage to your pipeline 
- Testing the CodePipeline automation 
  - Step 1: Change the application code to trigger pipeline 
  - Step 2: Verify the changes are deployed to the application

Initial Environment
-------------------

The initial environment depicts the architecture components deployed before using the AWS DevOps tools to deploy the application on ECS. The infrastructure includes:

![Image 3](./media/ecs-3.png)

1.  **Virtual Private Cloud (VPC):**

Created a VPC named **“MyVPC”** with an IPv4 CIDR block of 10.0.0.0/24.

![Image 4](./media/ecs-4.png)

2\. **Internet Gateway:**

Created and attached an internet gateway named **“My-Internet-Gateway”** to **“MyVPC”**.

![Image 5](./media/ecs-5.png)

3\. **Subnets:**

Created four subnets within “**MyVPC”**:

*   **Private-subnet-01** subnet: `10.0.0.0/28` .
*   **Private-subnet-02** subnet: `10.0.0.16/28` .
*   **Public-subnet-01** subnet: `10.0.0.32/28` .
*   **Public-subnet-02** subnet: `10.0.0.48/28` .

Created and associated the route tables with their respective subnets, so that public subnets can access the internet through the internet gateway and private subnets through the Nat Gateway.

![Image 6](./media/ecs-6.png)

4\. **NAT Gateway:**

Created and configured a **NAT Gateway** in the **public-subnet-01.**

![Image 7](./media/ecs-7.png)

5\. **Security Groups:**

Created and configured two security groups:

1) **web-app-alb-sg** (for the Application Load Balancer):

*   **Inbound Rules**: Allow access on port 80 from specific IP addresses that want to access the web application to be deployed.

2) **web-app-ecs-sg** (for ECS containers):

*   **Inbound Rules**: Allow access from the ALB security group **web-app-ALB-sg** on port 80.

Review the Application Artifact on GitHub Repository
----------------------------------------------------

Step 1: Review the source code on GitHub
----------------------------------------

The CI/CD workflow on AWS that we will build uses AWS DevOps tools, which require artifact files for the pipeline to function properly. We have already created a GitHub repository named **aws-ecs-deployment-pipeline** with the needed files. Ensure you create a repository and push the artifact files before proceeding with the demo.

The GitHub repository contains the following files:

![Image 8](./media/ecs-8.png)

GitHub Remote Repository

**Dockerfile**: The docker file contains instructions on how to build a new docker image to host a simple web application using Apache.
```dockerfile
# Use the latest Ubuntu image
FROM ubuntu:latest

# Install dependencies
RUN apt-get update
RUN apt-get -y install apache2

# Copy the index.html file to the container
COPY index.html /var/www/html/index.html

# Configure apache
RUN echo '. /etc/apache2/envvars' > /root/run_apache.sh && \
    echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh && \
    echo 'mkdir -p /var/lock/apache2' >> /root/run_apache.sh && \ 
    echo '/usr/sbin/apache2 -D FOREGROUND' >> /root/run_apache.sh && \ 
    chmod 755 /root/run_apache.sh

# Expose the necessary ports
EXPOSE 80

# Start Apache when the container runs
CMD /root/run_apache.sh
```

**index.html:** The HTML file serving the web application for the application.
```html
<!-- index.html -->
<html>
  <head>
    <title>Deployment of application on Amazon ECS</title>
    <style>body {margin-top: 40px; background-color: white;}</style>
  </head>
  <body>
    <div style="color:black; text-align:center">
      <h1>Congratulations !!!</h1>
      <h2>You have successfuly deployed the first version of your application on a container in Amazon ECS</h2>
    </div>
  </body>
</html>
```

**buildspec.yml**: A _buildspec_ is a collection of build commands in YAML format, that CodeBuild uses to run a build. In our case, we use AWS CodeBuild to build our web application image and push the image to Amazon ECR (For more information on how AWS CodeBuild works, check the [AWS CodeBuild Concepts](https://docs.aws.amazon.com/codebuild/latest/userguide/concepts.html)).
```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
    # - REPOSITORY_URI=<ACCOUNT-ID>.dkr.ecr.<REGION>.amazonaws.com/<APPLICATION-REPO-NAME> (To be changed later)
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $REPOSITORY_URI
      - IMAGE_TAG=build-$(echo $CODEBUILD_BUILD_ID | awk -F":" '{print $2}')
  build:
    commands:
      - echo Building the Docker image...
      - docker build -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Pushing the Docker images...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo Writing image definitions file...
      - printf '{"ImageURI":"%s"}' $REPOSITORY_URI:$IMAGE_TAG > imageDetail.json

artifacts:
  files:
    - imageDetail.json
```

The build specification **buildspec.yml** file provided does the following.

**_Pre-build stage_:** This phase prepares the environment and sets up prerequisites for the build process (used to log in to ECR or install npm dependencies).

1.  **Log in to Amazon ECR:**  
    Logs in to [AWS Elastic Container Registry](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) repository before building the docker image and pushing it to the repository.
2.  **Define the ECR repository URI:**  
    Specifies the target ECR repository URI where the Docker image will be pushed. This is defined as an environment variable `REPOSITORY_URI` where the commands are being executed. We will compile this part later when we create the AWS ECR repository.
3.  **Generate the image tag:**  
    Creates a unique tag for the Docker image by combining the `build-` prefix with the unique ID of the current build. **AWS CodeBuild provides several environment variables to use in your build commands. To learn more, check** [Environment variables in build environments](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-env-vars.html)**.**

**_Build stage_:** The build stage focuses on creating the Docker image.

1.  **Build the Docker image:**  
    Uses the `docker build` command to create a Docker image based on the `Dockerfile` in the source code. The image is tagged with `latest` by default.
2.  **Tag the Docker image with the build-specific tag:**  
    Adds tag to the image using the unique identifier (`$IMAGE_TAG`) generated in the Pre-build stage.

**_Post-build stage_:** This stage focuses on finalizing and pushing the built image.

1.  **Push the Docker images to Amazon ECR:**  
    Uploads both the `latest` and build specific tagged versions of the Docker image to the specified ECR repository.
2.  **Generate an image definitions file:**  
    Creates a JSON file (`imageDetail.json`) that contains in JSON format the URI of the build-specific Docker image.

**_Artifacts stage_:** Specifies the output files retained after the build process. This is called the build artifact and is saved into an S3 bucket managed by AWS CodePipeline, which acts as input for the next stages in the pipeline.

1.  **Image Definitions File (**`**imageDetail.json**`**):**  
    This file contains the URI of the newly built and pushed Docker image in JSON format.

**appspec.yaml**: The AppSpec file in AWS CodeDeploy for Amazon ECS applications specifies the task definition (via its ARN), the container, and the port for traffic routing during deployment. For more information about the AppSpec file for AWS ECS applications, check the [CodeDeploy AppSpec file reference](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html).

> The container name “web-app-container” specified in the appspec.yaml is the same name that we will use to deploy the ECS container in the next steps.
```yaml
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: <TASK_DEFINITION>
        LoadBalancerInfo:
          ContainerName: "web-app-container"
          ContainerPort: 80
```

Step 2: Create the elastic container registry to host the docker image
----------------------------------------------------------------------

1.  Go to the AWS ECR service console and create a repository.

![Image 9](./media/ecs-9.png)

2\. Name the repository **web-app-repo**.

![Image 10](./media/ecs-10.png)

Create ECR Image Repository

3\. Create the repository.

Step 3: Modify the BuildSpec file to contain the AWS ECR repository URI
-----------------------------------------------------------------------

In the **buildspec.yml**, replace the text after **REPOSITORY\_URI=** with the **URI** value for the Amazon Elastic Container Registry (Amazon ECR) **web-app-repo** repository created earlier.

You can get the URI value of the created AWS ECR repository from the private repositories dashboard:

![Image 11](./media/ecs-11.png)

The modified buildspec.yml file should look similar to this:
```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - REPOSITORY_URI=<account-number>.dkr.ecr.<your-region>.amazonaws.com/web-app-repo
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $REPOSITORY_URI
      - IMAGE_TAG=build-$(echo $CODEBUILD_BUILD_ID | awk -F":" '{print $2}')
  build:
    commands:
      - echo Building the Docker image...
      - docker build -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Pushing the Docker images...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo Writing image definitions file...
      - printf '{"ImageURI":"%s"}' $REPOSITORY_URI:$IMAGE_TAG > imageDetail.json

artifacts:
  files:
    - imageDetail.json
```

Save your changes to the **buildspec.yml** file and push them to the GitHub repository using the git commands:
```shell
git add .
git commit -m "Updated buildspec file"
git push
```

Create the Continuous Delivery Pipeline to Build your Application Image
-----------------------------------------------------------------------

Use the _AWS CodePipeline service_ to create the pipeline stages necessary for the continuous delivery of your application image.

Step 1: Create a pipeline using AWS CodePipeline
------------------------------------------------

To create the pipeline, complete the following steps:

1\. Navigate to AWS CodePipeline.

![Image 12](./media/ecs-12.png)

CodePipeline Dashboard

2\. On the **CodePipeline dashboard**, choose **Create pipeline**.

3\. Under **Creation option**, choose **Build custom pipeline**.

4\. On the **Choose pipeline settings** page, in the **Pipeline settings** section:

*   For the **Pipeline name**, enter web-app-pipeline.
*   For the **Execution mode,** select Queued.
*   For the **Service role**, choose New service role and leave the default role name.
*   Ensure the checkbox for “Allow AWS CodePipeline to create a service role so it can be used with this new pipeline” is checked.

![Image 13](./media/ecs-13.png)

Pipeline Settings

4\. Accept the default values for the remaining options and choose **Next**.

Step 2: Add stage for the application source code
-------------------------------------------------

In this step, we add a new stage to the pipeline to refer to the application source code. The application source code is hosted in the GitHub repository. By adding this stage, any changes you make to the source code are automatically detected and continuously integrated into the pipeline workflow. We add the repository **aws-ecs-deployment-pipeline** and **main** branch.

1.  On the **Add source stage** page, in the **Source** card, choose **AWS GitHub (via OAuth app)** for the **Source provider**. You will be prompted to log in to GitHub, after successfully logging in you will be able to select the source repository and branch.

![Image 14](./media/ecs-14.png)

Add Source Stage

> There are other ways to connect GitHub to AWS CodePipeline as source repository, choose the one that is compatible with your environment. To learn more check, [GitHub connections](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-github.html).

2\. On the **Add source stage** page, in the **Source** section:

*   For the **Repository name**, choose **aws-ecs-deployment-pipeline.**
*   For the **Branch name**, choose **main.**
*   For **Change detection options**, select **GitHub webhooks** **(recommended).**

3\. Choose **Next**.

Step 3: Add stage for building application code
-----------------------------------------------

In this step, we add a stage to build our application artifacts using **AWS CodeBuild**. AWS CodeBuild refers to the source code artifacts and builds the application based on the commands we provided in the build specification file.

> The source artifacts are produced in the source stage and saved in an S3 bucket managed by AWS CodePipeline service.

First, we need to create a **CodeBuild project** to create a build environment:

1.  In the Build card, choose **Other build providers**.
2.  Select **AWS CodeBuild** from the drop-down.
3.  Under **Project name**, click on **create project**.

![Image 15](./media/ecs-15.png)

Create Build Project

4\. On the **Create build project** page, in the **Project configuration** section:

*   For **Project name**, enter web-app-build-project.

5\. In the **Environment** section:

*   For **Environment image**, select **Managed image.**
*   For **Operating system**, choose **Ubuntu.**
*   For **Runtime(s)**, choose **Standard.**
*   For **Image**, choose **aws/codebuild/standard:7.0.**
*   For **Image version**, choose **Always use the latest image for this runtime version.**
*   For **Service role**, select New service role and leave the default name**.**
*   For **Privileged**, select the check box “**Enable this flag if you want to build Docker images or want your builds to get elevated privileges”.**
*   For **Build specifications:** choose, **Use a buildspec file**.

![Image 16](./media/ecs-16.png)

Build Project Part 1

![Image 17](./media/ecs-17.png)

Build Project Configuration Part 2

6\. Leave the remaining options with the default values and click “**Continue to CodePipeline**”.

After creating the CodeBuild project, we can proceed with the creation of the build stage inside the AWS CodePipeline pipeline:

1.  On the **Add build stage** page, in the **Build** — _optional_ section:

*   For **Build provider**, choose **AWS CodeBuild.**
*   For **Region**, make sure that you select the correct region where your pipeline exists.
*   For **Project name**, choose the previously created project **web-app-build-project.**

![Image 18](./media/ecs-18.png)

Build Stage Configuration

2\. For the **Build type** — _optional_, select **Single build** then Choose **Next**.

3\. On the **Add deploy stage** page, choose **Skip deploy stage** (we will add a deploy stage in later steps).

4\. On the **Review** page, review your selections for accuracy.

5\. choose **Create pipeline**.

After creating the pipeline, the execution of the pipeline will start automatically.

![Image 19](./media/ecs-19.png)

Pipeline Execution

> IMPORTANT: At this point the pipeline is expected to fail due to the absence of permissions associated with the service role “**codebuild-web-app-build-project-service-role**”.

Step 4: Pipeline execution failure resolution
---------------------------------------------

After a few minutes, the pipeline fails to execute due to the lack of permissions associated with the created service role “**codebuild-web-app-build-project-service-role**”.

![Image 20](./media/ecs-20.png)

Pipeline Execution Failure

To investigate the issue, click **View Details** on the build stage card. The error details provided by the pipeline can help you identify and debug potential problems affecting your pipeline.

![Image 21](./media/ecs-21.png)

Error Message Missing Permissions

AWS CodeBuild service requires permission to access AWS ECR so it can log in to the repository that contains the images. To solve this issue we need to add the missing permission to the role.

1.  Navigate to the IAM console.
2.  Under **Roles,** locate the role name **codebuild-web-app-build-project-service-role.**
3.  Click on the role name.
4.  Under **Permissions**, click on **Add permissions and Attach policies**.
5.  Locate and attach the policy **AmazonEC2ContainerRegistryPowerUser** (or you can attach a custom policy with fewer permissions).
6.  Click Add permissions to confirm the attaching of the policy.

![Image 22](./media/ecs-22.png)

IAM Service Role Permissions

Navigate back to the failed pipeline and click on **Release change** to restart the execution of the pipeline.

![Image 23](./media/ecs-23.png)

Restart Pipeline Execution

After adding the missing permissions, the pipeline execution now succeeds.

You can control the correct building and pushing of the docker image into the AWS ECR repository:

![Image 24](./media/ecs-24.png)

Create the ECS Cluster Components Manually to Support the Application Deployment
--------------------------------------------------------------------------------

In the following steps, we configure the ECS cluster to allow the deployment of the application image. We define an ECS task definition to refer to the application container image hosted in the ECR repo with the necessary configuration details. Then, we define an ECS service to run containers based on the task definition behind a load balancer to support the traffic distribution once the blue/green deployment goes live.

Step 1: Create AWS ECS cluster and ECS task definition
------------------------------------------------------

In this step, we create an ECS task definition named _WebAppTaskDefinition_ to run on a container instance in the cluster. Later, we will create the task definition file to use a placeholder variable _IMAGE1\_NAME_ variable to refer to the latest images created during the pipeline workflow, this allows for the dynamic deployment of the latest images.

**Creation of the AWS ECS cluster:**

1\. Navigate to Elastic Container Service.

2\. Create a cluster and configure the settings:

*   Cluster name: WebAppCluster.
*   Infrastructure: AWS Fargate (serverless).

**Create the task definition:**

After creating the cluster, go to **Task Definitions** and create a new task definition:

*   Family Name: **WebAppTaskDefinition**.
*   Launch type: **AWS Fargate**.
*   Task size: **1 CPU and 2 GB RAM**.
*   Task role: leave empty.
*   Task execution role: Select **Create new role**.

![Image 25](./media/ecs-25.png)

Task Definition Configuration

Container-1 configurations:

*   Container Name: **web-app-container**.
*   URI Image: URI of web application image pushed to ECR.
*   Port Mapping: keep it on port 80.
*   Leave other default configurations.

![Image 26](./media/ecs-26.png)

Task Definition Container Configuration

We will use the task definition in the next steps to deploy the AWS ECS service.

Step 2: Create the AWS application load balancer
------------------------------------------------

In this step, we will create the application load balancer that will be attached to the AWS ECS service that will be created in step 3.

1\. Navigate to EC2 Console.

2\. Click on **Load Balancers** and then on **Create Load Balancer**.

3\. Click **Create on the Application Load Balancer** section.

4\. Name the load balancer “**web-app-alb**” and select the **Internet-facing Scheme** and **IPv4 IP address type**.

![Image 27](./media/ecs-27.png)

Basic Configuration

5\. In the network mapping section, select “**MyVPC**” and the two availability zones where you deployed the subnets “**Public-subnet-01**” and “**Public-subnet-02**”.

![Image 28](./media/ecs-28.png)

Network Mapping

6\. In the security group, select the security group “**web-app-alb-sg**” created earlier.

![Image 29](./media/ecs-29.png)

Security Group

7\. Under the **listeners and routing section**, select HTTP as protocol and port 80.

![Image 30](./media/ecs-30.png)

Listeners and Routing

8\. Click on **Create Target Group** and open a new tab.

9\. On the **Basic configuration** page:

*   For **Choose a target type**, select **IP addresses.**
*   For **Target group name**, name it **web-app-tg**.

![Image 31](./media/ecs-31.png)

Target Group Basic Configuration Part 1

*   For **Protocol : Port**, choose the **HTTP Protocol and Port 80.**
*   For **IP address type**, choose **IPv4.**
*   For **VPC**, select **MyVPC.**

![Image 32](./media/ecs-32.png)

Target Group Basic Configuration Part 2

*   For **Health checks**, select **HTTP and the default root path.**

![Image 33](./media/ecs-33.png)

10\. Click on the Next button.

11\. On the Register targets page:

*   For **Network**, select **MyVPC.**
*   For **Specify IPs and define ports**, no need to register any IP addresses (we will do it at the level of AWS ECS service).

![Image 34](./media/ecs-34.png)

Register Targets

12\. Click on **Create target group**.

13\. Go to your **Create Load Balancer page’s listeners and routing section**, press the refresh button, and select your target group that was just created.

![Image 35](./media/ecs-35.png)

Select Target Group

14\. Leave other default settings and click **Create load balancer**.

Step 3: Create the AWS ECS service with AWS CodeDeploy handler
--------------------------------------------------------------

Configuring blue/green deployment requires two separate environments — in this case, represented by two target groups. One target group manages the currently running application (blue environment), while the other is designated for the new version of the application to be deployed (green environment). The load balancer performs a seamless transition by gradually shifting traffic from the old environment to the new one, ensuring minimal downtime and safe deployment.

**Create a second target group for blue/green deployment:**

We will create a new target group similar to the first one created before **web-app-tg.**

1.  Navigate to the EC2 console.
2.  Under **Load Balancing**, click on **Target Groups**.
3.  **Create a target group**.
4.  On the **Basic configuration** page:

*   For **Choose a target type**, select **IP addresses.**
*   For **Target group name**, name it **web-app-tg-2**.
*   For **Protocol : Port**, choose the **HTTP Protocol and Port 80.**
*   For **IP address type**, choose **IPv4.**
*   For **VPC**, select **MyVPC.**
*   For **Health checks**, select **HTTP and the default root path.**

5\. Click on the Next button.

6\. On the Register targets page:

*   For **Network**, select **MyVPC.**
*   For **Specify IPs and define ports**, no need to register any IP addresses.

7\. Click on **Create target group**.

**Create the ECS service:**

After creating the second target group, we are ready to create a new ECS service. Go to the created cluster **WebAppCluster** and **create a new service**.

1\. On the **Create** page:

*   For **Compute options**, select **Capacity provider strategy** (leave defaults: Base = 0, Weight = 1)**.**

![Image 36](./media/ecs-36.png)

Configuring Environment

*   For **Application type**, select **Service**.
*   For **Family,** choose the task definition **WebAppTaskDefinition** with the latest revision.
*   For **Service name**, name it **web-app-service**.
*   Under **Service type,** select **Replica with 1 desired task** (you can put 2 for High Availability).

![Image 37](./media/ecs-37.png)

Deployment Configuration

Under **Deployment options**:

*   For **Deployment type**, select **Blue/green deployment (powered by AWS CodeDeploy).**
*   For **Deployment configuration**, select **CodeDeployDefault.ECSAllAtOnce**.
*   For **Service role for CodeDeploy**, choose **CodeDeploy\_Service\_Role.** (If you do not have the service role, refer to [Amazon ECS CodeDeploy IAM Role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/codedeploy_IAM_role.html) for creating it).

![Image 38](./media/ecs-38.png)

On the **Networking** card:

*   For **VPC**, choose **MyVPC**.
*   For **Subnets,** select the “**Private-subnet-01**” and “**Private-subnet-02**” subnets.
*   For **Security group,** select the **web-app-ecs-sg.**
*   Ensure that **PUBLIC IP is OFF.**

![Image 39](./media/ecs-39.png)

Configuring Networking Part

Under the **Load balancing — optional** card:

*   For **Load balancer type**, choose **Application Load Balancer.**
*   For **Container**, leave the default one.
*   For **Application Load Balancer**, use an **existing load balancer** and select the created load balancer **web-app-alb.**

![Image 40](./media/ecs-40.png)

Configure Application Load Balancer

*   For **Listener**, use an **existing listener** and select the **80:HTTP**.
*   For **Target groups**, choose the previously created target groups **web-app-tg** and **web-app-tg-2**.

![Image 41](./media/ecs-41.png)

Configure Target Groups

Leave other **default configurations** and **create the service**.

Step 4: Create the taskdef.json file and push changes to the source code repository
-----------------------------------------------------------------------------------

While the AWS ECS service is being deployed, we can create the **taskdef.json** file and push the file to the GitHub repository.

The **taskdef.json** file defines the AWS ECS task definition in JSON format. This file is essential for the pipeline to function correctly, so it should be included in the source artifact. During deployment, the **deploy stage** in the pipeline will dynamically register a new task definition referencing the updated Docker images.

After creating the task definition from the console, click on the created task definition.

![Image 42](./media/ecs-42.png)

Under the JSON tab, copy the provided JSON code and save it in a file named **taskdef.json.**

![Image 43](./media/ecs-43.png)

To dynamically change the URI of the image inside the task definition in future deployments, we change the task definition file to use a placeholder variable **_IMAGE1\_NAME_** variable to refer to the latest images created during the pipeline workflow.

On line **6** of the **taskdef.json** file, replace the entire text after the image field **“image”:** with the “<IMAGE1\_NAME\>” image placeholder.

Once the changes are made as suggested, the **taskdef.json** should appear similar to:
```json
{
    "taskDefinitionArn": "<Task-Definition-ARN>",
    "containerDefinitions": [
        {
            "name": "web-app-container",
            "image": "<IMAGE1_NAME>",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "web-app-container-80-tcp",
                    "containerPort": 80,
                    "hostPort": 80,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [],
            "environmentFiles": [],
            "mountPoints": [],
            "volumesFrom": [],
            "ulimits": [],
            "systemControls": []
        }
    ],
    "family": "WebAppTaskDefinition",
    "executionRoleArn": "arn:aws:iam::<Account-Number>:role/ecsTaskExecutionRole",
    "networkMode": "awsvpc",
    "revision": 1,
    "volumes": [],
    "status": "ACTIVE",
    "requiresAttributes": [
        {
            "name": "com.amazonaws.ecs.capability.ecr-auth"
        },
        {
            "name": "ecs.capability.execution-role-ecr-pull"
        },
        {
            "name": "com.amazonaws.ecs.capability.docker-remote-api.1.18"
        },
        {
            "name": "ecs.capability.task-eni"
        }
    ],
    "placementConstraints": [],
    "compatibilities": [
        "EC2",
        "FARGATE"
    ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "1024",
    "memory": "2048",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    }
}
```

> Important Note: To avoid problems when deploying the pipeline, in the taskdef.json make sure to remove the “registeredAt”, “registeredBy” and “tags” lines.

The docker image in the **taskdef.json** file gets dynamically updated with the latest image URI by AWS CodeDeploy in the pipeline for future deployments.

Save your changes to the **taskdef.json** file and push the changes to the GitHub repository using the git commands:
```shell
git add .
git commit -m "add taskdef file"
git push
```

Configure the Deploy Stage in the Pipeline
------------------------------------------

Check the correct functioning of the application
------------------------------------------------

By making the required application source code available and configuring the ECS service in the previous steps, we have manually deployed the application.

In this step, we will confirm the correct functioning of the application:

1.  Navigate to EC2 Console.
2.  Under **Load Balancing**, click on **Load Balancers**.
3.  Locate the Application load balancer **web-app-alb** DNS URL and access it.
4.  Open a new browser tab and enter the load balancer’s **public DNS name** that you copied, it should show the application website greeting page:

![Image 44](./media/ecs-44.png)

> In case you are unable to access the web application using the load balancer DNS URL, ensure that the application load balancer security group allows your IP address on port 80.

Configure the Blue/Green Deployment using the Deploy Stage
----------------------------------------------------------

Step 1: Review the CodeDeploy application and deployment group
--------------------------------------------------------------

After the AWS ECS service is created, AWS CodeDeploy automatically sets up the application and deployment group. These will be used to configure the Deploy stage in AWS CodePipeline.

In the **CodePipeline** web browser tab, under **Deploy \> CodeDeploy** choose **Applications**.

1\. You notice that a new Application has been created named **AppECS-WebAppCluster-web-app-service.**

2\. Click on the name of the application.

![Image 45](./media/ecs-45.png)

3\. In the **Deployment groups** section, check if the **deployment group** has been correctly created. It should be named **DgpECS-WebAppCluster-web-app-service**.

4\. Click on the **deployment group name** and control all the configured settings.

![Image 46](./media/ecs-46.png)

The important settings are:

*   Compute platform: Amazon ECS.
*   Deployment type: Blue/green
*   Service role ARN: CodeDeploy\_Service\_Role ARN.
*   Deployment Configuration: CodeDeployDefault.ECSAllAtOnce.
*   ECS cluster name: WebAppCluster.
*   ECS service name: web-app-service.
*   Load Balancing Configurations.

Step 2: Add the deploy stage to your pipeline
---------------------------------------------

1.  In the left navigation pane, under **Pipeline \> CodePipeline** choose **Pipelines**.
2.  Choose the text link for **web-app-pipeline**.
3.  Choose **Edit**, and configure the following options:

*   Below the **Edit: Build** stage card, choose **Add stage**.
*   For **Stage name**, enter Deploy.
*   Choose **Add stage**

4\. On the **Edit: Deploy** card, choose **Add action group**.

5\. In the **Edit action** pop-up window:

*   For **Action name**, enter web-app-deploy.
*   For **Action provider**, choose **Amazon ECS (Blue/Green).**
*   Choose the region where the code pipeline exists.
*   For **Input artifacts**, choose **SourceArtifact** and **BuildArtifact.**
*   For **AWS CodeDeploy application name**, choose **AppECS-WebAppCluster-web-app-service.**
*   For **AWS CodeDeploy deployment group**, choose **DgpECS-WebAppCluster-web-app-service.**
*   For **Amazon ECS task definition**, choose **SourceArtifact** and enter taskdef.json.
*   For **AWS CodeDeploy AppSpec file**, choose **SourceArtifact** and enter appspec.yaml.
*   For **Input artifact with image details**, choose **BuildArtifact.**
*   For **Placeholder text in the task definition**, enter IMAGE1\_NAME.

6\. Choose **Done**.

7\. On the **Editing: web-app-pipeline** page, choose **Save**.

8\. From the **Save pipeline changes** pop-up window, choose **Save**.

Testing the CodePipeline automation
-----------------------------------

Step 1: Change the application code to trigger pipeline
-------------------------------------------------------

We make a simple update to your application by changing the text displayed in the HTML file, then we push changes to the GitHub repo to deploy the changes automatically.

1.  Navigate to the files of the repository and locate the file **index.html**.
2.  Change the displayed text in the HTML to “You have successfully deployed the second version of your application on a container in Amazon ECS”.
```html
<!-- index.html -->
<html>
  <head>
    <title>Deployment of application on Amazon ECS</title>
    <style>body {margin-top: 40px; background-color: white;}</style>
  </head>
  <body>
    <div style="color:black; text-align:center">
      <h1>Congratulations !!!</h1>
      <h2>You have successfully deployed the second version of your application on a container in Amazon ECS</h2>
    </div>
  </body>
</html>
```

3\. Push the modified code to the remote repository, this will trigger the changes automatically and deploy them.
```shell
git add .
git commit -m "Modify HTML file"
git push
```

Step 2: Verify the changes are deployed to the application
----------------------------------------------------------

1.  Go to the **CodePipeline — AWS Developer Tools** web browser tab.
2.  Once the progress reaches the _Deploy_ stage, review the deployment details using CodeDeploy.
3.  You can click on **Details** to view the deployment when the **web-app-deploy** card shows the action is in progress.
4.  Choose the **Deployment Id** link that is in progress.

![Image 47](./media/ecs-47.png)

**Note:** Take time to review details. Notice the various stages of the deployment process and how the traffic is shifting from the blue to the green environment.

![Image 48](./media/ecs-48.png)

To skip Step 3 which waits one hour by default before terminating the original task, click on **Terminate original task set.**

Return to the browser you opened with the **load balancer’s public DNS name**. Refresh the browser until you notice that the text of the website has changed.

![Image 49](./media/ecs-49.png)

Congratulations! You have verified that the pipeline is handling blue/green deployments of code changes automatically into the ECS environment.

