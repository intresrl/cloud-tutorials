# AIM
This project install a static website on a GCP bucket, you can find an article about this project [here](https://TODO/).


# Arguments

## Required
- project_id: The GCP project id 

## Optional
- location: The location of the bucket (default is "europe-west8", Milan) 
- bucket_name: The name of the bucket (default is "static-website-bucket"). A random string is added to the name to avoid conflicts.

# Installation procedure
```
terraform init
terraform apply -var project_id=temp-423715
```