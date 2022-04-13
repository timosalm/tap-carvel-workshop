As mentioned, with **secretgen-controller** it's possible to generate various types of Secrets in-cluster as well as export and import Secrets across namespaces.

##### Generating Secrets
The generation of the following Secret types is supported: Certificates (CAs and leafs), Passwords, RSA Keys, and SSH Keys.

You will create the following Password Secret via kapp now.
```editor:append-lines-to-file
file: secgc-password.yaml
text: |2
  apiVersion: secretgen.k14s.io/v1alpha1
  kind: Password
  metadata:
    name: postgresql-password
```

```terminal:execute
command: kapp deploy -a postgresql-password -f secgc-password.yaml -y
clear: true
```

Via the following command you should now be able to see the generated Secret object.
```terminal:execute
command: kapp inspect -a postgresql-password --tree
clear: true
```

Let's have a closer look at the generated secret.
```terminal:execute
command: kubectl get secret postgresql-password -o yaml
clear: true
```
By default, generated secrets have a predefined set of keys. In a lot of cases, Secret consumers expect a specific set of keys within data. With the **Secret Template** functionality, it's possible to customize the keys within a secret.

For our Password Secret this can be done like this:
```editor:append-lines-to-file
file: secgc-password.yaml
text: |2
  spec:
    secretTemplate:
      type: Opaque
      stringData:
        postgresql-pass: \$(value)
```

```execute
kapp delete -a postgresql-password -y
kapp deploy -a postgresql-password -f secgc-password.yaml -y
```
```terminal:execute
command: kubectl get secret postgresql-password -o yaml
clear: true
```

##### Exporting and Importing Secrets to other Namespaces

Access to Secrets is commonly scoped to its containing namespace. In some cases an owner of a Secret may want to export it to other namespaces for consumption by other resources in the system. 
With the two CRDs **SecretExport** and **SecretImport** (and "placeholder secrets"), secretgen-controller enables sharing of Secrets across namespaces.

For the installation of TAP, the credentials to fetch container images from Tanzu Network are required in several namespaces. 
For a better installation experience for our customers, the Tanzu CLI is used instead of applying the CRDs manually to share those credentials.

With the `--export-to-all-namespaces` flag of the `tanzu secret registry add` command, in addition to a Secret of type kubernetes.io/dockerconfigjson, a **SecretExport** resource with the same name will be created, which makes the secret available across all namespaces in the cluster. For the TAP installation the `tap-registry` secret is created like this to allow the fetching of containers from the Tanzu Network for all the components.

Let's now create create an example secret in the workshop namespace and after that import it in the workshop session namespace.
```execute
tanzu secret registry add example-registry-{{ session_namespace }} \
  --username {{ session_namespace }} --password tanzu \
  --server example.vmware.com \
  --export-to-all-namespaces --namespace carvel-workshop-examples --yes
```
You can have a look at the created Secret and the SecretExport.
```terminal:execute
command: kubectl get Secret example-registry-{{ session_namespace }} -n carvel-workshop-examples
clear: true
```
```execute
kubectl get SecretExport.secretgen.carvel.dev example-registry-{{ session_namespace }} -n carvel-workshop-examples -o yaml
```

Namespaces of Learning Center workshop sessions are by default annotated with `secretgen.carvel.dev/excluded-from-wildcard-matching: ""` so that users are not able to get access to credentials of e.g. the TAP installation that are offered to export to all namespaces. 
Let's therefore manually change our SecretExport to only offer secrets for export to our namespace to be able to import it.

```terminal:execute
command: kubectl get SecretExport.secretgen.carvel.dev example-registry-{{ session_namespace }} -n carvel-workshop-examples -o yaml > secgc-export.yaml
clear: true
```
```editor:select-matching-text
file: secgc-export.yaml
text: "- '*'"
```
```editor:replace-text-selection
file: secgc-export.yaml
text: "- {{ session_namespace }}"
```
```execute
kubectl apply -f secgc-export.yaml
```

To share this Secret with a our session namespace, you have to create a **SecretImport** custom resource.
```editor:append-lines-to-file
file: secgc-import.yaml
text: |2
  apiVersion: secretgen.carvel.dev/v1alpha1
  kind: SecretImport
  metadata:
    name: example-registry-{{ session_namespace }}
  spec:
    fromNamespace: carvel-workshop-examples
```
```terminal:execute
command: kubectl apply -f secgc-import.yaml
clear: true
```

Now there should be the `example-registry-{{ session_namespace }}` Secret in the session namespace created by the SecretImport.
```terminal:execute
command: kubectl get secret example-registry-{{ session_namespace }}
clear: true
```

**Placeholder Secrets** are an alternative to SecretImport to import image pull secrets exported via SecretExport.

A placeholder secret is:
- a plain Kubernetes Secret
- with kubernetes.io/dockerconfigjson type
- has secretgen.carvel.dev/image-pull-secret annotation

After you have deleted our SecretImport ...
```execute
kubectl delete -f secgc-import.yaml
```
... you are able to apply the placeholder secret.
```execute
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: example-registry-{{ session_namespace }}
  annotations:
    secretgen.carvel.dev/image-pull-secret: ""
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: e30K
EOF
```
The value of the `.dockerconfigjson` key is set to `{}` encoded in Base64.
Now let's check whether the secret data was successfully imported.
```terminal:execute
command: kubectl get secret example-registry-{{ session_namespace }} -o yaml
clear: true
```

Execute the following command to clean up the directory.
```execute
kapp delete -a postgresql-password -y
kubectl delete secret example-registry-{{ session_namespace }}
tanzu secret registry delete example-registry-{{ session_namespace }} --namespace carvel-workshop-examples --yes
kubectl delete -f secgc-import.yaml
kubectl delete -f secgc-export.yaml
rm secgc-password.yaml
rm secgc-import.yaml
rm secgc-export.yaml
```