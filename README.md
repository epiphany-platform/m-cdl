# m-cdl

Epiphany Module: Common Data Layer

# Basic usage

## Build image

In main directory run:

  ```shell
  make build
  ```

## Run module

* Create a shared directory:

  ```shell
  mkdir /tmp/shared
  ```

  This 'shared' dir is a place where all configs and states will be stored while working with modules.

* Generate ssh keys in: /tmp/shared/vms_rsa.pub

  ```shell
  ssh-keygen -t rsa -b 4096 -f /tmp/shared/vms_rsa -N ''
  ```

* Initialize CDL module:

  ```shell
  make run STEP=init
  ```

* Plan and apply AwsBI module:

  ```shell
  make run STEP=plan
  make run STEP=apply
  ```

  Running those commands should create a bunch of AWS resources (resource group, vpc, subnet, ec2 instances and so on). You can verify it in AWS Management Console.

## Run module with provided example

### Prepare config file

Prepare your own variables in vars.mk file to use in the building process.
Sample file (examples/basic_flow/vars.mk.sample):

  ```shell
  AWS_ACCESS_KEY_ID = "xxx"
  AWS_ACCESS_KEY_SECRET = "xxx"
  ```

### Create an environment

  ```shell
  cd examples/basic_flow
  make all
  ```

or step-by-step:

  ```shell
  cd examples/basic_flow
  make init
  make plan
  make apply
  ```

### Delete environment

  ```shell
  cd examples/basic_flow
  make all-destroy
  ```

or step-by-step

  ```shell
  cd examples/basic_flow
  make destroy-plan
  make destroy
  ```

## Release module

  ```shell
  make release
  ```

or if you want to set a different version number:

  ```shell
  make release VERSION=number_of_your_choice
  ```
