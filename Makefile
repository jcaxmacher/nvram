.PHONY: build
.PHONY: push

build:
	hugo -t lanyon-hugo

push:
	aws --profile publisher s3 sync ./public/ s3://aws-website-non-volatilememory-spll5
