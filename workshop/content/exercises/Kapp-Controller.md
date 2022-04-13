As mentioned **kapp-controller** provides package management and continuous delivery capabilities by utilizing `kapp` to track the resources, it’s deploying.

kapp-controller has three primary use cases, which we will talk about:
- Continuous Delivery
- Package Consumption
- Package Authoring

##### Continuous Delivery
kapp-controller's **App** CRD provides a declarative way to install, manage, and upgrade applications on a Kubernetes cluster.

```editor:append-lines-to-file
file: kappctl-spring-petclinic.yaml
text: |
  apiVersion: kappctrl.k14s.io/v1alpha1
  kind: App
  metadata:
    name: spring-petclinic-kappctl
  spec:
    serviceAccountName: default
    fetch:
    - git:
        url: https://github.com/vmware-tanzu/carvel-simple-app-on-kubernetes
        ref: origin/develop
        subPath: config-step-2-template
    template:
    - ytt:
        inline:
          paths:
            values.yaml: |
              #@data/values
              ---
              hello_msg: "Hello TAP"
            ns-overlay.yaml: |
              #@ load("@ytt:overlay", "overlay")

              #@overlay/match by=overlay.all, expects="1+"
              ---
              metadata:
                #@overlay/match missing_ok=True
                #@overlay/remove
                namespace: ""
    deploy:
    - kapp: {}
```

If you deploy the App, kapp-controller will fetch the GitHub repo, template the subPath for us using ytt to override the default configuration values, and then create the resources for us.
```terminal:execute
command: kubectl apply -f kappctl-spring-petclinic.yaml
clear: true
```
```terminal:execute
command: kubectl get app.kappctrl.k14s.io spring-petclinic-kappctl
clear: true
```
```terminal:execute
command: kubectl get service,deployment,pods
clear: true
```

Let's execute the following command to clean up the directory and look at the **Package consumption** and **authoring** use-cases for the TAP installation in the next section.
```execute
kubectl delete -f kappctl-spring-petclinic.yaml
rm kappctl-spring-petclinic.yaml
```