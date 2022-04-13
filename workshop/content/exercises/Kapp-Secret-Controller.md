**kapp-controller** provides package management and continuous delivery capabilities by utilizing `kapp` to track the resources it’s deploying.

With **secretgen-controller** it's possible to generate various types of Secrets in-cluster as well as export and import Secrets across namespaces.

Before you have a closer look at both, let's first have a look how they have to be installed for TAP if you use another **distribution than TKG 1.5**. It's possible to install them via the instructions on https://carvel.dev, but for our customers, we are offering a better installation experience via the **Cluster Essentials for VMware Tanzu**.