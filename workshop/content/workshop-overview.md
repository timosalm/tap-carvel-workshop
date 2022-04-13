The goal of this workshop is to get familiar with all the tools **Carvel** provides and how they are used for the installation of VMware Tanzu Application Platform.

##### Custom Kubernetes resources

VMware Tanzu Application Platform(TAP) relies heavily on Kubernetes **custom resources**.

A **resource** is an endpoint in the Kubernetes API that stores a collection of API objects of a certain kind. For example, the built-in pods resource contains a collection of Pod objects.

A **custom resource** is an extension of the Kubernetes API. It represents a customization of a particular Kubernetes installation. However, many core Kubernetes functions are now built using custom resources, making Kubernetes more modular.

The CustomResourceDefinition API resource allows you to define custom resources. Defining a **Custom Resources Definition (CRD)** object creates a new custom resource with a name and schema that you specify. 

With the following command, you can have a look at the CRDs already installed in the cluster.
```terminal:execute
command: kubectl get crds
clear: true
```

##### Introduction to Carvel

To aid in application building, configuration, and deployment in Kubernetes in the form of YAML files, we use the open source **Carvel** suite of tools (formerly known as k14s).

```dashboard:create-dashboard
name: Carvel
url: https://carvel.dev
```

It currently contains the following non-experimental tools:
- **kapp-controller**: Capture application deployment workflow declaratively via App CRD. Reliable GitOps experience powered by kapp.
- **ytt**: Template and overlay Kubernetes configuration via YAML structures, not text documents. No more counting spaces, or manual quoting.
- **kapp**: Install, upgrade, and delete multiple Kubernetes resources as one “application”. Be confident your application is fully reconciled.
- **kbld**: Build or reference container images in Kubernetes configuration in an immutable way.
- **imgpkg**: Bundle and relocate application configuration (with images) via Docker registries. Be assured app contents are immutable.
- **vendir**: Declaratively state what files should be in a directory.

And also some experimental tools:
- **kwt**: Expose Kubernetes overlay network to your machine. No more port mapping, or starting multiple proxies.
- **terraform-provider-carvel**: Use ytt, kbld, and/or kapp in your Terraform module.
- **secretgen-controller**: Generate various types of Secrets in-cluster as well as export and import Secrets across namespaces.

Let's have a closer look at those tool to be able to understand what happens during the installation of TAP.
```dashboard:delete-dashboard
name: Carvel
```