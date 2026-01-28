# Create GDP Collector for VMware

## Introduction

Use this example to create a GDP Collector on VMware.

## Summary of process

The Terraform scripts should be run in this order.

1. Configure the Terraform process.
2. Run the Terraform process. This will create a Collector.

## 1. Edit the parameters

Create the file terraform.tfvars based on the example file.

```
cp terraform.tfvars.example terraform.tfvars
```

Edit the file and enter the parameters for your installation.

```
vi terraform.tfvars
```

After you have verified the parameters, save the file and exit the editor.

Next, edit the instances.json file.

```
vi instances.json
```

Here you will enter all the parameters for your specific vSphere installations, as well as parameters for the Collector you are going to build.

Note that you must enter the IP address of the Central Manager you created earlier if you want this Collector to be registered to it.

## 2. Run the Terraform process

Start by initializing Terraform.

```
terraform init
```

Then set up Terraform to run the process you have defined.

```
terraform plan
```

Finally, run the process.

```
terraform apply
```

You will be prompted to enter "yes" after a few seconds. Then the process will run until it completes. This could take up to 45 minutes.

## 3 Connect to GDP

Connect to GDP via a browser with a URL like this:

```
https://ip-address:8443
```

You can then begin using GDP. In the login screen:
* User: `admin`
* Password: `the password you created in the Central Manager` 
