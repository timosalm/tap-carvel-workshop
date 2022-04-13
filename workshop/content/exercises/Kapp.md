**kapp** is a lightweight application-centric tool for deploying resources on Kubernetes. Being both explicit and application-centric, it provides an easier way to deploy and view all resources created together regardless of what namespace they’re in. 

##### Deploying an App
Let’s go ahead and deploy our first application with kapp!

Create kapp-spring-petclinic.yaml file with a Spring PetClinic namespace, deployment, and service:

```editor:append-lines-to-file
file: kapp-spring-petclinic.yaml
text: |2
  ---
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: spring-petclinic
  spec:
    selector:
      matchLabels:
        app: spring-petclinic
    replicas: 2
    template:
      metadata:
        labels:
          app: spring-petclinic
      spec:
        containers:
        - name: spring-petclinic
          image: springcommunity/spring-framework-petclinic
          ports:
          - name: http
            containerPort: 8080
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: spring-petclinic
    labels:
      app: spring-petclinic
  spec:
    ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
    selector:
      app: spring-petclinic
    type: ClusterIP
```

Now let's use kapp to create our deployment and service.
```terminal:execute
command: kapp deploy -a spring-petclinic -f kapp-spring-petclinic.yaml
clear: true
```
This format is fairly similar to `kubectl apply -f kapp-spring-petclinic.yaml`, but it also has an application name. You can also provide a directory instead of a single file.
The next difference you will notice is it prompts you if you want to actually run the command. You can shortcut this by adding the `-y` flag.

A more significant difference with kubectl. kapp will wait on the resources to become available before terminating and will also show the progress for each resource and tell you if it succeeded or failed.

Now that you have the deployment and service up.
```terminal:execute
command: kubectl get deployment,service spring-petclinic
clear: true
```

##### Looking At the App
You can take a look at everything you have running with kapp using the following command:
```terminal:execute
command: kapp list
clear: true
```
To see all of the resources kapp created for the app, you can use kapp inspect:
```terminal:execute
command: kapp inspect -a spring-petclinic
clear: true
```
```terminal:execute
command: kapp inspect -a spring-petclinic --tree
clear: true
```
You can also look at logs, which is especially useful if something fails after the pods are up. `kapp logs` will show all pod logs in the app.
```terminal:execute
command: kapp logs -a spring-petclinic
clear: true
```

##### Updating the App
Let’s make a change to the YAML file and try running it again.
```editor:select-matching-text
file: kapp-spring-petclinic.yaml
text: "ClusterIP"
```
```editor:replace-text-selection
file: kapp-spring-petclinic.yaml
text: "LoadBalancer"
```
And then let’s run our kapp command again, but with -c to see a diff of the changes.
```terminal:execute
command: kapp deploy -a spring-petclinic -c -f kapp-spring-petclinic.yaml
clear: true
```
To see the applied changes, run:
```terminal:execute
command: kubectl get svc
clear: true
```
##### Deleting the App
To delete the app you can run the following command:
```execute
kapp delete -a spring-petclinic -y
```














