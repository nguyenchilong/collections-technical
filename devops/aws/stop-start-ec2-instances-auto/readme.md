# How to Stop/Start EC2 Instances Using AWS Step Functions
- For some time, I have been extensively working with [AWS Step Functions](https://docs.aws.amazon.com/step-functions/latest/dg/welcome.html) with different workloads, and I'm continually amazed by how powerful this tool is.
- It was then that I had the idea to conduct some tests and attempt to address tasks that we might consider `common`, and to see how I could resolve these using only the resources provided directly within the Step Functions pipeline, without resorting to any additional resources.
- I remember that in every company I have worked for, or nearly every one, we had [EC2 instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) running that needed to be stopped, whether to save costs or for scheduled maintenance.
- That said, let's explore how this will work. For my tests, I'm using [Terraform](https://developer.hashicorp.com/terraform/intro) to deploy this into my AWS account.

## Terraform
- As with almost everything in AWS, we will need to create a role and some policies that will allow the Step Function to start and stop our instances.
```terraform

variable "name" {
  type        = string
  description = "Resource name"
  default     = "StopStartEc2Automatically"
}

resource "aws_iam_role" "sfn_this" {
  name               = "StepFunction${var.name}"
  assume_role_policy = data.aws_iam_policy_document.sfn_trust.json
}

data "aws_iam_policy_document" "sfn_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "sfn_this" {
  name   = "StepFunctionEC2Permissions"
  policy = data.aws_iam_policy_document.sfn_this.json
  role   = aws_iam_role.sfn_this.id
}

data "aws_iam_policy_document" "sfn_this" {
  statement {
    sid = "DescribeEc2"
    actions = [
      "ec2:DescribeInstances"
    ]
    resources = ["*"]
  }

  statement {
    sid = "StopStartEc2"
    actions = [
      "ec2:StopInstances",
      "ec2:StartInstances"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Stop"
      values   = ["True"]

    }
  }

  statement {
    sid = "SQSSendMessage"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.this.arn
    ]
  }
}

```
- We'll also need to create another role and policy, but I thought it best to pause and explain why I've included permission to publish messages to an [AWS SQS](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html) queue. I did this because, by the end of this article, we will have a complete Terraform setup, and with it, we will create a new queue where we can publish a message in case of a pipeline failure. This is useful for error handling and monitoring.
```terraform

resource "aws_iam_role" "cloudwatch_this" {
  name               = "CloudWatch${var.name}"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_trust.json
}

data "aws_iam_policy_document" "cloudwatch_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "cloudwatch_this" {
  name   = "CloudWatchStepFunctionPermissions"
  policy = data.aws_iam_policy_document.cloudwatch_this.json
  role   = aws_iam_role.cloudwatch_this.id
}

data "aws_iam_policy_document" "cloudwatch_this" {
  statement {
    sid = "StartSfnExecution"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.this.arn
    ]
  }
}

```
- As I mentioned earlier, I have added a new role and policy. This will be necessary to schedule with [AWS EventBridge](https://docs.aws.amazon.com/scheduler/latest/UserGuide/what-is-scheduler.html) when our pipeline will stop or start the EC2 instances.
- After creating all the necessary policies for our pipeline works, let us now proceed to create our new SQS queue.
```terraform
resource "aws_sqs_queue" "this" {
  name = "${var.name}Failed"
}
```
- After writing this complex three-line code to create our queue, we can finally begin creating our AWS Step Functions.
```terraform
resource "aws_sfn_state_machine" "this" {
  name     = var.name
  role_arn = aws_iam_role.sfn_this.arn

  definition = templatefile("${path.module}/step_function.json", {
    aws_sqs_queue_url  = aws_sqs_queue.this.url
    aws_sqs_queue_name = aws_sqs_queue.this.name
  })
}
```
- We'll now need to add what I dislike most about the process of creating an AWS Step Function, the creation of the JSON file that the pipeline will use to work. This might seem straightforward, but I have had the opportunity to work with Step Functions that had hundreds lines, and it can become quite confusing over time.
- It is noticeable that I used [templatefile](https://developer.hashicorp.com/terraform/language/functions/templatefile) on definition. This is because we want inset dynamically the values for URL and name of the SQS queue that we created earlier.
```json

{
	"Comment": "State machine to Start or Stop EC2 instances",
	"StartAt": "ListInstances",
	"States": {
		"ListInstances": {
			"Type": "Task",
			"Resource": "arn:aws:states:::aws-sdk:ec2:describeInstances",
			"Parameters": {
				"Filters": [
					{
						"Name": "tag:Stop",
						"Values": [
							"True"
						]
					}
				]
			},
			"ResultPath": "$.listResult",
			"Next": "CheckInstances",
			"Catch": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"ResultPath": "$.errorInfo",
					"Next": "PostSQSMessageError"
				}
			]
		},
		"CheckInstances": {
			"Type": "Choice",
			"Choices": [
				{
					"And": [
						{
							"Variable": "$.listResult.Reservations",
							"IsPresent": true
						},
						{
							"Variable": "$.listResult.Reservations",
							"IsNull": false
						},
						{
							"Variable": "$.listResult.Reservations[0]",
							"IsPresent": true
						}
					],
					"Next": "Action"
				}
			],
			"Default": "NoInstances"
		},
		"NoInstances": {
			"Type": "Succeed",
			"Comment": "No EC2 instances found with the specified tag."
		},
		"Action": {
			"Type": "Choice",
			"Choices": [
				{
					"Variable": "$.Action",
					"StringEquals": "Stop",
					"Next": "StopInstances"
				},
				{
					"Variable": "$.Action",
					"StringEquals": "Start",
					"Next": "StartInstances"
				}
			]
		},
		"StopInstances": {
			"Type": "Task",
			"Resource": "arn:aws:states:::aws-sdk:ec2:stopInstances",
			"Parameters": {
				"InstanceIds.$": "$.listResult.Reservations[*].Instances[*].InstanceId"
			},
			"End": true,
			"Catch": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"ResultPath": "$.errorInfo",
					"Next": "PostSQSMessageError"
				}
			]
		},
		"StartInstances": {
			"Type": "Task",
			"Resource": "arn:aws:states:::aws-sdk:ec2:startInstances",
			"Parameters": {
				"InstanceIds.$": "$.listResult.Reservations[*].Instances[*].InstanceId"
			},
			"End": true,
			"Catch": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"ResultPath": "$.errorInfo",
					"Next": "PostSQSMessageError"
				}
			]
		},
		"PostSQSMessageError": {
			"Type": "Task",
			"Resource": "arn:aws:states:::aws-sdk:sqs:sendMessage",
			"Parameters": {
				"QueueUrl": "${aws_sqs_queue_url}",
				"MessageBody.$": "$.errorInfo"
			},
			"Next": "Failed"
		},
		"Failed": {
			"Type": "Fail",
			"Error": "StateMachineError",
			"Cause": "An error occurred on state machine execution, check queue ${aws_sqs_queue_name} for more information."
		}
	}
}

```
- To be honest, this JSON looks quite daunting, but if we examine it key by key, we should be able to understand better how it works.
- If we go back to the beginning of this article, we can observe that in the permissions policy for our Step Functions, I included a condition to grant the pipeline permissions only for EC2 instances that have the tag `Stop=True`. With that said, in the first key, `ListInstances`, the pipeline will list all instances that have this tag.
- On `CheckInstances` key, the pipeline will check if all the conditions on choice are met, then proceed to the next step `Action`. If no instances with the previously defined tag are found, it will be directed to the `NoInstances` step, which will end the pipeline with a `Succeed` status.
- Now, let's define the action on `Action` key. This step, we essentially have two options that will be triggered based on our EventBridge.
- As mentioned, we'll have two actions or keys in this JSON, `StopInstances` and `StartInstances`. The names of the actions are self-explanatory. In this case, if the instances are stopped or started successfully, the pipeline will complete without any errors. However, if for any reason any of these steps fail, we will be directed to the `PostSQSMessageError` step, which will publish the message generated by the Step Functions on queue and then terminate the pipeline with a failure.
- Now we need to create the events that will trigger the pipeline.
```terraform

resource "aws_cloudwatch_event_rule" "stop" {
  name                = "StopInstancesRule"
  description         = "Stop instances at 22:00"
  schedule_expression = "cron(0 22 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "start" {
  name                = "StartInstancesRule"
  description         = "Start instances at 08:00"
  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "stop" {
  rule  = aws_cloudwatch_event_rule.stop.name
  arn   = aws_sfn_state_machine.this.arn
  input = jsonencode({ "Action" : "Stop" })

  role_arn = aws_iam_role.cloudwatch_this.arn
}

resource "aws_cloudwatch_event_target" "start" {
  rule  = aws_cloudwatch_event_rule.start.name
  arn   = aws_sfn_state_machine.this.arn
  input = jsonencode({ "Action" : "Start" })

  role_arn = aws_iam_role.cloudwatch_this.arn
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = "${var.name}Failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alarm when Step Function ${aws_sfn_state_machine.this.name} failed"
  dimensions = {
    QueueName = aws_sqs_queue.this.name
  }
}

```
- On this final terraform configuration, I added two automatic triggers that will stop the instances every day at 22:00 and then start them again at 08:00.
- It is possible to note that in `aws_cloudwatch_event_target` we have an **input** option, which is a small JSON like `{ “Action” : “Stop” }` or `{ “Action” : “Start” }`. This is how we trigger an AWS Step Function. Therefore, if manual intervention is required, simply start a new execution with this small JSON.
- Do you remember at the beginning of the article when I mentioned creating alerts based on SQS queue messages? Well, I have added an alarm that will trigger if a message is sent to this queue.

## The end
- Thank you for following me on this journey so far.
- I hope this sparks an interest in exploring different options with AWS Step Functions, such as ECS tasks, EKS, and others.
