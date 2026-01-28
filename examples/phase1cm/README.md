# Create GDP Central Manager for VMware

## Introduction

Use this example to create a GDP Central Manager on VMware.

## Summary of process

1. Configure the Terraform process.
2. Run the Terraform process. This will create an Aggregator that can be converted to a Central Manager.
3. Manually accept the GDP license.
4. Run the "run_guardium_phase2.sh" script to convert the Aggregator to a Central Manager.

The instructions for running the Terraform scripts (steps 1 and 3) are below. Information about step 2 and connecting the appliances to each other are in the [further instructions document](../../docs/further_instructions.md).

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

Here you will enter all the parameters for your specific vSphere installations, as well as parameters for the Central Manager you are going to build.

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

## 3. Connect to GDP

Connect to GDP via a browser with a URL like this:

```
https://ip-address:8443
```

You can then begin using GDP. In the login screen:
* User: `admin` 
* Password: `the default password from instances.json` 

You will be prompted to immediately change the password.

Now go to the License screen and accept the license that has been stored there. You can also add further licenses at this time.

## 4. Run the conversion script

Back in Linux, run the conversion script with this command.

```
./run_guardium_phase2.sh
```

You will find this script in the `modules/central_manager` directory.

This will convert the GDP appliance to a Central Manager.