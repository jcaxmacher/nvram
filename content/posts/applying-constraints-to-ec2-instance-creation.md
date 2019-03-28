+++
date = "2018-09-10T10:15:46-04:00"
title = "Applying Constraints to EC2 Instance Creation"
draft = true
tags = ["aws", "ec2", "iam", "cloudformation"]
+++

It has been said that Amazon Web Services provides ["building
blocks"](https://medium.com/tieto-developers/use-aws-services-as-building-blocks-to-implement-your-enterprise-system-598676a0ee49).
While that's true, the sheer number of block shapes, colors and styles
even just within the flagship EC2 service is enough to make one paralyzed by
choice.  It's no wonder that those who have proven mastery of AWS services
through experience and certification
[command](https://www.indeed.com/salaries/Amazon-Aws-Professional-Salaries)
[such](https://www.ziprecruiter.com/Salaries/AWS-Solution-Architect-Salary)
[high](https://www.businessinsider.com/salary-survey-indicates-employers-prize-amazon-aws-certifications-2017-8)
[salaries](https://www.globalknowledge.com/us-en/content/articles/what-it-takes-to-earn-a-top-paying-aws-certification/).

## The Setup

So, let's say you have a group of developers (let's call them Dev Team A) that need a few servers to run and
test their latest code.  You want to give them self-service access to EC2, but
do not want them wasting their time trying to understand the difference between
`t3.small` and `idk.8xlarge`, puzzling over how subnets relate to availability
zones, or accidentally deploying into production.  Additionally, this group of
developers is just one of many and you want each team to have full
responsibility (particularly for cost) for their EC2 instances and no way to
interfere with any other team's resources.

## The Recipe

The first tool we need from our toolbox is Identity and Access Management (IAM).  The EC2
API has partial support for [resource-level
IAM permissions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-supported-iam-actions-resources.html)
which means we can grant permisssion not just to certain API calls, but also
which resources those API calls can act upon.

We'll create an IAM policy for Dev Team A
which will permit them to (in order from least to most complex IAM permissions):

  1. List EC2 instances
  2. Stop, Start and Terminate their own instances
  3. Create new EC2 instances

### Listing EC2 Instances

The `ec2:DescribeInstances` API call does not have resource-level permissions,
so the statement for our IAM policy that grants this permission is very simple:

```
{
    "Sid": "AllowToDescribeAll",
    "Effect": "Allow",
    "Action": [
        "ec2:Describe*"
    ],
    "Resource": "*"
}
```

Then, members of Dev Team A can filter the results of that API call with their
department tag:

```

```

### Stop, Start and Terminate EC2 Instances

We want to limit which instances Dev Team A can stop, start and terminate.  To
do this we will use condition keys in our statement that allows the
`ec2:StopInstances`, `ec2:StartInstances` and `ec2:TerminateInstances` API calls
for all resources which have the tag `Department=Dev Team A`:

```
{
    "Sid": "AllowDevTeamAStartStopTerminate",
    "Effect": "Allow",
    "Action": [
        "ec2:StopInstances",
        "ec2:StartInstances",
        "ec2:TerminateInstances"
    ],
    "Resource": "*",
    "Condition": {
        "StringEquals": {
            "ec2:ResourceTag/Department": "Dev Team A"
        }
    }
}
```
