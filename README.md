# Carvel self-paced learning workshop for the installation of TAP

A [Learning Center for VMware Tanzu](https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-learning-center-about.html) workshop for self-paced learning of all the tools Carvel provides for the installation of TAP

## Workshop installation
Download the Tanzu CLI for Linux from https://network.tanzu.vmware.com/products/tanzu-application-platform to the root of the directory.
Create a public project called **tap-workshop** and private project called **tap-carvel-workshop-examples** in your registry instance. 

There is a Dockerfile in the root directory of this repo. From that root directory, build a Docker image and push it to the project you created:
```
docker build . -t <your-registry-hostname>/tap-workshop/tap-carvel-workshop
docker push <your-registry-hostname>/tap-workshop/tap-carvel-workshop
```

Copy values-example.yaml to values.yaml and set configuration values
```
cp values-example.yaml values.yaml
```
Run the installation script.
```
./install.sh
```

## Debug
```
kubectl logs -l deployment=learningcenter-operator -n learningcenter
```