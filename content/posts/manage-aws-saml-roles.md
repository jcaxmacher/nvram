---
title: "Manage AWS Saml Roles for G Suite Users"
linktitle: "Manage AWS Saml Roles for G Suite Users"
date: 2019-03-11
author: "Jeremy Axmacher"
draft: false
tags: ["aws", "python", "gsuite", "mfa", "saml", "iam"]
---

I recently setup G Suite (aka Google Apps for Work) as the SAML IdP for my
personal AWS account following [these instructions](https://aws.amazon.com/blogs/security/how-to-set-up-federated-single-sign-on-to-aws-using-google-apps/).  Once it was done, I had
a very simple way to log into my AWS console using my existing G Suite credentials.

![SAML
architecture](https://dmhnzl5mp9mj6.cloudfront.net/security_awsblog/images/WD_2.png)

Now I no longer need to remember my IAM user password (well, it was in a password
manager, but it's one less thing) and I get the additional benefit of my G
Suite-configured MFA settings.  I like this a lot better than the MFA that
AWS provides for IAM users because Google's [2-Step verification phone prompts](https://gsuiteupdates.googleblog.com/2017/10/making-google-prompt-primary-choice-for-2sv.html) make MFA so simple.

## API Access

However, I had one more requirement for IAM users- AWS API access.  Thankfully,
someone has [already created a solution](https://github.com/cevoaustralia/aws-google-auth)
for getting temporary AWS Access Keys using the Google Apps SAML provider.  You
simply provide a few key pieces of information to the tool's command line
interface:

```
aws-google-auth -u user@yourgsuitedomain.com -I I3892idw, -S 834286658791 -R us-east-1 -d 3600 -a
```

This tool even triggers the MFA phone prompts I've configured for my account.
The `-a` flag causes it to prompt for selection of the desired AWS role, so if
you've configured multiple roles for a G Suite user you can select which one you
want the access keys for.  The access keys are then written to your AWS
credentials file under the `sts` profile name (though there is a flag to specify
a different name).

## Roles for Identity Federation

Now that I had my G Suite user configured with a custom schema and an AWS IAM
role (see the first link, about one third down the page), I wanted an simple way
to add and remove roles from my user account.

I believe the principle of least privilege is very important, so I am always crafting
new IAM policies that try to limit the permissions to exactly what's needed and only that.  Naturally, this requires lots of iteration and testing.
[CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-role.html)
is the best way quickly create and destroy IAM policies and
[roles for Identity Federation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_saml.html)

Here's an example CloudFormation template I was using test limiting of access to
EC2 Instance creation:

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Resources:
  DevTeamEC2Role:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          -
            Effect: "Allow"
            Action: "sts:AssumeRoleWithSAML"
            Principal:
              Federated: !Sub "arn:aws:iam::${AWS::AccountId}:saml-provider/GoogleApps"
            Condition:
              StringEquals:
                SAML:aud: https://signin.aws.amazon.com/saml
      Path: "/"
      Policies:
        -
          PolicyName: "DevTeamStopStartTerminate"
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              -
                Sid: "AllowDevTeamStartStopTerminate"
                Effect: "Allow"
                Action: 
                - "ec2:StopInstances"
                - "ec2:StartInstances"
                - "ec2:TerminateInstances"
                Resource: "*"
                Condition:
                  StringEquals:
                    "ec2:ResourceTag/Department": "Dev Team A"
Outputs:
  RoleName:
    Description: "The ARN of the role created"
    Value: !GetAtt DevTeamEC2Role.Arn
```

With that template, I can quickly create the role and policy I want to test:

```
aws --profile sts cloudformation create-stack --stack-name devteam --template-body file://teststopstart.yaml --capabilities CAPABILITY_IAM
... after a minute or so ...
aws --profile sts cloudformation describe-stacks --stack-name devteam
```

The `describe-stacks` API call will give me the name of the role created.  Now
how do I quickly add it to my G Suite user?

## Multiple Roles

I began with [the code here](https://developers.google.com/admin-sdk/directory/v1/quickstart/python)
which uses the G Suite Directory API to list out
users in my G Suite domain and then modified it to patch the custom schema (the
one added when the identity federation was setup.  [The command line tool I
created](https://github.com/jcaxmacher/google-cloud-aws-role-helper) adds or
removes roles to the given user.

It requires some secret OAuth information, so I stored those in AWS Secrets Manager
and the command line tool downloads them right before making the G Suite
Directory API calls.  For example, this invocation adds the role `ServerlessDev`
(it's name in AWS) to my user `frank@custom.com`:

```
python modify_roles.py sts GoogleApps frank@custom.com ADD ServerlessDev
```

Now, I can quickly create roles and policies for test and just as quickly add
them to my G Suite user.  Then it's back to the `aws-google-auth` tool to get
temporary access keys for that role.
