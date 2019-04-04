---
title: "Building a URL Shortener on AWS using the AWS CDK"
linktitle: "An AWS CDK URL Shortener"
date: 2019-03-15
author: "Jeremy Axmacher"
draft: true
tags: ["aws", "cdk", "code", "iaac"]
---

With the introduction of the AWS CDK, there's a great new way to create cloud resources on Amazon Web Services.  I have been kicking the tires on it since watching the re:Invent talk "Infrastructure is Code" a few weeks ago.  What I have found will not be surprising to anyone who comes from a software engineering background - using an actual\* programming language for creating cloud resources is a much more enjoyable experience than writing CloudFormation templates. <strong>If you use AWS in a business context, you should strongly consider [assessing and possibly trialing](http://nealford.com/memeagora/2013/05/28/build_your_own_technology_radar.html#assess) the AWS CDK for creating cloud resources.</strong>

Kudos to everyone who has worked on the CloudFormation documentation because it is a great resource, but if you have spent any time at all working with CloudFormation you know how large the API is, how many optional properties resources sometimes have, how many different ways those optional properties can sometimes be combined, and how tricky linking resources using intrinsic functions can sometimes be.  Declarative infrastructure through JSON or YAML CloudFormation templates is a vast improvement to unrepeatable and unmaintainable point-and-clicking, but YAML is not a bicycle for the mind.  The feedback loop is just too long- write some text in YAML, create a stack or changeset, execute it, watch the output, see where you went wrong. 

It comes down to ergonomics (i.e., human efficiency in their working environment)- using a statically-typed language (like TypeScript, C# or Java) with an editor that has IntelliSense (Visual Studio Code) significantly increases productivity by shortening the feedback loop (i.e., how quickly do you know you've got something that works or doesn't work) when using a large third-party API like CloudFormation resource types and properties.  On top of that, the CDK provides a library of "constructs" that go way beyond "CloudFormation templates in a statically typed programming language" by giving you a higher-level API with intelligent defaults.

## An Example - URL Shortener

A few months ago I came across [a very nice blog post on how to create a Serverless URL Shortener on AWS](https://blog.ruanbekker.com/blog/2018/11/30/how-to-setup-a-serverless-url-shortener-with-api-gateway-lambda-and-dynamodb-on-aws/).  With serverless technologies like Lambda, DynamoDB and API Gateway, a scalable URL shortening service can be created in a very small number of steps.  I wondered how easy it would be to spin up this same service (using the same\* business logic) using the AWS CDK.  If you want, jump to the repository to see the full example code in one place.

### Pre-requisites

If you want to follow along, configure the pre-requisites defined in AWS CDK
workshop site.  Additionally, if want to have the URL shortener service
available at a custom domain, you'll need a public hosted DNS zone in Route 53
already available (the zone is not created here).

You'll need to make a project folder and initialize a new CDK application in
that folder.  Additionally, we need to install a few AWS CDK modules from npm
which correspond to the cloud resources we'll be creating with the CDK.

{{< highlight bash >}}
mkdir url-shortener && cd url-shortener
cdk init --language typescript
npm install @aws-cdk/aws-dynamodb @aws-cdk/aws-lambda @aws-cdk/aws-apigateway
{{< / highlight >}}

### Creating the API Gateway, DynamoDB Table and Lambda Functions

Open `./lib/url-shortener-stack.js` in Visual Studio Code and add the following imports near the top of
the file:

{{< highlight typescript "linenos=table,linenostart=2" >}}
import cdk = require('@aws-cdk/cdk');
import dynamodb = require('@aws-cdk/aws-dynamodb');
import lambda = require('@aws-cdk/aws-lambda');
import apigw = require('@aws-cdk/aws-apigateway');
{{< / highlight >}}

Next, we begin adding the resources within our stack:

{{< highlight typescript "linenos=table,linenostart=9" >}}
class UrlShortenerStack extends cdk.Stack {
  constructor(parent: cdk.App, name: string, props?: cdk.StackProps) {
    super(parent, name, props);

    // Create the API Gateway Rest API resource
    const api = new apigw.RestApi(this, 'UrlShortenerApi')
{{< / highlight >}}

We subclass the `cdk.Stack` class on line 9 and within our `UrlShortenerStack` class
constructor (on line 14), we create an instance of the API Gateway `RestApi`
construct (not to be confused with a TypeScript class constructor, a "construct" is CDK terminology) class.
By passing `this` as the first parameter to the `RestApi` constructor, we link
it to our `Stack`.  The second parameter becomes part of the CloudFormation
logical ID for the resources.  There is an optional third parameter which can
be used to configure API settings, but the defaults are all we need for this
example.

Next, we use another construct to
create a DynamoDB table with a similarly minimal amount of required information:

{{< highlight typescript "linenos=table,linenostart=16" >}}
    // Create the DynamoDB table resource
    const table = new dynamodb.Table(this, 'UrlShortenerTable', {
      partitionKey: {
        name: 'short_id',
        type: dynamodb.AttributeType.String
      }
    });
{{< / highlight >}}

Our instance of the DynamoDB construct is again linked to the `this` of our `UrlShortenerStack` class.
In the third parameter, we specify an instance of `TableProps` which contains
our partition key definition (each `short_id` is the key we use to lookup the
original URLs in the table).  

Next, we define our AWS Lambda functions (I will not include the function code
in this article- if you want to understand the Lambda function code, read the original blog post by
Ruan Bekker or click through to my repository).  One function will receive HTTP
requests to create short URLs when given the original URL in a JSON-encoded HTTP
POST body:

{{< highlight typescript "linenos=table,linenostart=24" >}}
    // Create the lambda function resource which allows creation of short URLs
    const createUrlHandler = new lambda.Function(this, 'UrlShortenerUrlCreateFn', {
        runtime: lambda.Runtime.Python36,
        handler: 'create.handler',
        code: lambda.Code.asset('lambda'),
        environment: {
          DB_NAME: table.tableName,
          MIN_CHAR: '5',
          MAX_CHAR: '10'
        }
    });
    // Create a Lambda Proxy integration for our lambda function
    const createUrlHandlerIntegration = new apigw.LambdaIntegration(createUrlHandler);
    // Link the integration to a resource and method on the API
    api.root.addMethod('POST', createUrlHandlerIntegration);
    // Grant read/write table access to our function
    table.grantReadWriteData(createUrlHandler.role);
{{< / highlight >}}

The Lambda function (beginning on line 25), is another high-level CDK construct.
On lines 26-29, we define the runtime, specify the function handler (the handler
function in the `create` module), bundle the code in the lambda folder of our
project, and begin defining the environment variables.

One of the nice things about this construct is how easy the call to
`lambda.Code.asset` (line 28) makes bundling the code for our Lambda function.
The second thing that's important to note is the clean reference to the DynamoDB
table name on line 30.  There's no need to know the underlying physical name of
the table and we do not need to know how to use Ref or any other CloudFormation
intrinsic function.

On line 36, we create a Lambda Proxy integration for our function and on line
38, we link that integration to the HTTP POST method on the root of our API.
The CDK handles creating the permission for the API to invoke the Lambda
function.  Line 40 provides the permission for our function to read and write to
our DynamoDB table.  The IAM policy (scoped to the one DynamoDB table
resources) and the IAM role needed by our function are created automatically.

{{< highlight typescript "linenos=table,linenostart=42" >}}
    // Create the lambda function resource which redirects from short URL to long URL
    const retrieveUrlHandler = new lambda.Function(this, 'UrlShortenerUrlRetrieveFn', {
        runtime: lambda.Runtime.Python36,
        handler: 'retrieve.handler',
        code: lambda.Code.asset('lambda'),
        environment: {
          DB_NAME: table.tableName
        }
    });
    // Create a Lambda Proxy integration for our lambda function
    const retrieveUrlHandlerIntegration = new apigw.LambdaIntegration(retrieveUrlHandler);
    // Link the integration to a resource and method on the API
    api.root.addResource('t').addResource('{shortid}').addMethod('GET', retrieveUrlHandlerIntegration);
    // Grant read/write table access to our function
    table.grantReadWriteData(retrieveUrlHandler.role);
{{< / highlight >}}

The next Lambda function is for retrieving original URLs when a short URL is
requested.  The only difference between this function and our create function is
on line 54, where we define the resource path and a path parameter to allow HTTP
GET requests to `/t/{shortid}` to be routed to the retrieve function.

Lastly, we create a CDK app, instantiate our `UrlShortenerStack`, link it to the app and run it.

{{< highlight typescript "linenos=table,linenostart=74" >}}
const app = new cdk.App();
new UrlShortenerStack(app, 'UrlShortenerStack');
app.run();
{{< / highlight >}}

When we run our CDK code, these are the commands that will actually create our
cloud resources.  Before executing the `cdk` commands, we need [AWS credentials defined in a
credentials file or through environment
variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).
Then we can bootstrap the CDK and deploy the stack:

{{< highlight bash >}}
npm run build # This will compile our TypeScript code to JavaScript
cdk bootstrap
cdk deploy
{{</ highlight >}}

We can also use `cdk synth` command to output the CloudFormation
template created by the CDK for review before deploying.

### A Custom Domain for our URL Shortener API

Without a short DNS name, our URL Shortener will not actually provider shorter
URLs.  Rather than include the resources to add a custom domain directly in our stack,
we can create our own construct that will let us add a custom domain to any
API Gateway API.  First we install a few more CDK modules:

{{< highlight bash >}}
npm install @aws-cdk/aws-certificatemanager
npm install @aws-cdk/aws-route53
{{</highlight>}}

Then, we add a new TypeScript module in the lib folder and call it
`./lib/custom-api-domain.ts`. 

{{< highlight typescript "linenos=table,linenostart=1" >}}
import cdk = require('@aws-cdk/cdk');
import apigw = require('@aws-cdk/aws-apigateway');
import acm = require('@aws-cdk/aws-certificatemanager');
import route53 = require('@aws-cdk/aws-route53');
{{</ highlight >}}

We start the module by importing the needed modules.  Then, we define the
interface to our construct. This is done by creating a TypeScript interface with
the properties our construct needs to function and optional properties which
provide additional possibilities for customizing the resources our construct
creates:

{{< highlight typescript "linenos=table,linenostart=6" >}}
export interface CustomApiGatewayDomainProps {
    apiRef: apigw.RestApiRef;
    apiDomain: string;
    stageName: string;
    apiDnsTtl?: number;
    certificateArn?: string;
    certificateDomain?: string;
    endpointConfigurationType?: apigw.EndpointType;
}
{{</highlight>}}

Our required properties are `apiRef`, `apiDomain` and `stageName`.  This is the
minimum information needed to attach a custom domain name to an API Gateway API.
*One big assumption is that the `apiDomain` is a DNS name for which a hosted
zone exists in Route 53.*

If only those three properties are provided, the
construct will try to create an ACM certificate for the `apiDomain`. This will
result in an email with instructions to verify the certificate request when our
stack is deployed.  If the `certificateDomain` is supplied, the DNS name on the
certificate request will be `certificateDomain` instead of `apiDomain`.  This
allows us to request a wildcard certificate.

If we specify the `certificateArn`, the construct will use that ACM certificate instead of
creating one.  This allows us to use an existing certificate (maybe we already
have a wildcard certificate?).

The `apiDnsTtl` allows configuration of the time-to-live value for the DNS CNAME
record that the contruct will create for `apiDomain`.  Finally, the
`endpointConfigurationType` allows us to specify if the API Gateway endpoint for
our custom domain should be regional or edge (i.e., should it use CloudFront
edge locations for API distribution).

Next, we subclass `cdk.Construct` to begin building our construct:

{{< highlight typescript "linenos=table,linenostart=16" >}}
export class CustomApiGatewayDomain extends cdk.Construct {
    constructor(parent: cdk.Construct, id: string, props: CustomApiGatewayDomainProps) {
        super(parent, id);
{{</highlight>}}

On line 17, we specify that the constructor for our `CustomApiGatewayDomain`
construct takes an instance of our `CustomApiGatewayDomainProps` interface as
the third parameter.  When we add an instance of this construct to our stack,
this is how we'll pass our options in.

{{<highlight typescript "linenos=table,linenostart=21">}}
        // Default options
        const endpointConfigurationType = (props.endpointConfigurationType === undefined) ? 'REGIONAL': props.endpointConfigurationType;
        const apiDnsTtl = (props.apiDnsTtl === undefined) ? 300 : props.apiDnsTtl;
        const certificateDomain = (props.certificateDomain === undefined) ? props.apiDomain : props.certificateDomain;

        // Construct Apex Domain from API domain
        const apex = props.apiDomain.split('.').slice(1).join('.');
{{</highlight>}}

Some of our optional properties need default values, so we define them here.  We
set the default endpoint configuration type to regional (because CloudFront
deploys are soooo slow).  We default our DNS record TTL to 300 seconds.  And, we
default our certificate domain to be the same as our API domain.  Then, on line
27, we chop out the domain apex for our API domain name.

{{<highlight typescript "linenos=table,linenostart=28">}}
        // Create or import an ACM certificate resource with the given domain
        let certificate: acm.CertificateRef;
        if (props.certificateArn) {
            certificate = acm.Certificate.import(this, 'ImportedCert', {
                certificateArn: 'asdf'
            });
        } else {
            certificate = new acm.Certificate(this, 'CustomApiGatewayDomainCertificate', {
                domainName: certificateDomain
            });
        }
{{</highlight>}}

Depending on whether or not our construct was provided the `certificateArn`
property, we either import an existing certificate (using the ARN), or we create
a new ACM certificate using a high-level construct from the CDK.  *Remember, that
creating a certificate this way requires verification by email and that stack
deployment will sit waiting for that verification process to complete.*

{{<highlight typescript "linenos=table,linenostart=40">}}
        // Create a custom domain name resource for API Gateway
        // ** Uses cloudformation directly **
        const customDomain = new apigw.CfnDomainName(this, 'CustomApiGatewayDomainName', {
          domainName: props.apiDomain,
          regionalCertificateArn: certificate.certificateArn,
          endpointConfiguration: {
            types: [
              endpointConfigurationType
            ]
          }
        });
{{</highlight>}}

Next, we create our custom domain resource in API Gateway.  This does not use a
high-level construct.  We use a construct that maps directly to the same-named
resource type in CloudFormation.  These CloudFormation constructs are a part of
each module's interface (e.g., API Gateway, Lambda, etc.), but are prefixed with
`Cfn`.  The properties passed to these contructs in the third parameter directly
maps to the properties available on this resource type in CloudFormation.

On line 43-45, we provide the domain name, the certificate ARN and the endpoint
configuration. Next we create our base path mapping which links our API (and one
of its deployment stages) to the custom domain we just created:

{{<highlight typescript "linenos=table,linenostart=52">}}
        // Create a new base path mapping resource
        // ** Uses cloudformation directly **
        new apigw.CfnBasePathMapping(this, 'ApiGatewayBasepathMapping', {
          restApiId: props.apiRef.restApiId,
          domainName: customDomain.domainNameName,
          stage: props.stageName,
          basePath: ''
        });
{{</highlight>}}

## Summary

So, for about 77 lines of code we deploy a fully-functional URL Shortening service-- not too bad.  Technology continues to advance at an amazing rate as we all collectively learn (and re-learn sometimes) the best way of doing things.  Once again, I believe the AWS CDK is an example of what the future of cloud infrastructure looks like and if you work in the cloud space, you should definitely give it a test run.
