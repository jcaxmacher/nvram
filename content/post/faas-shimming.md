+++
date = "2018-08-20T17:15:46-04:00"
title = "Shimming apps into FaaS"
draft = true
tags = ["serverless", "python", "zappa"]
+++

Deployment tools and application wrappers like
[Zappa](https://github.com/Miserlou/Zappa), [Serverless
Java container](https://github.com/awslabs/aws-serverless-java-container) and
[AWS Serverless Express](https://github.com/awslabs/aws-serverless-express)
make it easy to move web applications into Function-as-a-Service (FaaS) platforms like
[AWS Lambda](https://aws.amazon.com/lambda/).  Those tools have a very nice
value proposition:

  - Get the benefits (pay for what you use, high availability, low operational overhead, etc.) of a FaaS platform with zero\* application changes
  - Prevent FaaS platform lock-in by allowing you to stay with your existing application
    protocol or container (e.g., Tomcat, WSGI or HTTP)

<p style="font-size: 0.75rem">
There may be some wrapper code required.  This also assumes your app already follows Twelve-Factor principles (specifically, <a href="https://12factor.net/backing-services">the one about backing services</a>) and each HTTP request completes in under five minutes.
</p>

These tools allow a new kind of "lift and shift" for moving from legacy
platforms to cloud providers.  Let's explore the benefits and disadvantages of different degrees of embracing FaaS platforms.

In my own experience, I have seen large users of cloud avoid more deeply
integrated, platform-specific cloud offerings 
