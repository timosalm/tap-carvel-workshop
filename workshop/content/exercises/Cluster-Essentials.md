The instructions on how to install the **Cluster Essentials for VMware Tanzu** can be found in the TAP product documentation.
```dashboard:open-url
url: {{ ENV_TAP_PRODUCT_DOCS_BASE_URL }}/GUID-install-general.html#tanzu-cluster-essentials
```

For the installation, you can use the [pivnet CLI](https://github.com/pivotal-cf/pivnet-cli) to download the Cluster Essentials for VMware Tanzu archive from Tanzu Network as an alternative to the browser.
```dashboard:open-url
url: https://network.tanzu.vmware.com/products/tanzu-cluster-essentials/
```

```section:begin
title: If you have an API key for VMware Tanzu Network available ...
```
... run the login command of the pivnet CLI to be able to have a closer look at the installation script of the Cluster Essentials for VMware Tanzu.
```terminal:input
text: pivnet login --api-token=
endl: false
```

You can then run the following commands to download and unpack the archive.
```terminal:execute
command: pivnet download-product-files --product-slug='tanzu-cluster-essentials' --release-version='1.0.0' --product-file-id=1105818
clear: true
```
```terminal:execute
command: mkdir tanzu-cluster-essentials && tar -xvf "tanzu-cluster-essentials-linux-amd64-1.0.0.tgz" -C tanzu-cluster-essentials
clear: true
```
Let's have a look at the install script, which uses the Carvel tools ytt, imgpkg, and kbld to install kapp- and secretgen-controller.
```editor:open-file
file: tanzu-cluster-essentials/install.sh
line: 1
```
```section:end
```

```section:begin
title: If you don't have an API key for VMware Tanzu Network available ...
```
... let's just have a look at the example install script provided with this workshop which could change in future Cluster Essentials for VMware Tanzu versions. It uses the Carvel tools ytt, imgpkg, and kbld to install kapp- and secretgen-controller.

{% raw %}
```editor:append-lines-to-file
file: tanzu-cluster-essentials-install.sh
text: |2
  #!/bin/bash

  set -e -o pipefail

  # Note script should be idempotent

  if command -v xattr &>/dev/null; then
    xattr -d com.apple.quarantine imgpkg kapp kbld ytt 1>/dev/null 2>&1 || true
  fi

  ns_name=tanzu-cluster-essentials
  echo "## Creating namespace $ns_name"
  kubectl create ns $ns_name 2>/dev/null || true

  echo "## Pulling bundle from $INSTALL_REGISTRY_HOSTNAME (username: $INSTALL_REGISTRY_USERNAME)"

  [ -z "$INSTALL_BUNDLE" ]            && { echo "INSTALL_BUNDLE env var must not be empty"; exit 1; }
  [ -z "$INSTALL_REGISTRY_HOSTNAME" ] && { echo "INSTALL_REGISTRY_HOSTNAME env var must not be empty"; exit 1; }
  [ -z "$INSTALL_REGISTRY_USERNAME" ] && { echo "INSTALL_REGISTRY_USERNAME env var must not be empty"; exit 1; }
  [ -z "$INSTALL_REGISTRY_PASSWORD" ] && { echo "INSTALL_REGISTRY_PASSWORD env var must not be empty"; exit 1; }

  export IMGPKG_REGISTRY_HOSTNAME_0=$INSTALL_REGISTRY_HOSTNAME
  export IMGPKG_REGISTRY_USERNAME_0=$INSTALL_REGISTRY_USERNAME
  export IMGPKG_REGISTRY_PASSWORD_0=$INSTALL_REGISTRY_PASSWORD
  ./imgpkg pull -b $INSTALL_BUNDLE -o ./bundle/

  export YTT_registry__server=$INSTALL_REGISTRY_HOSTNAME
  export YTT_registry__username=$INSTALL_REGISTRY_USERNAME
  export YTT_registry__password=$INSTALL_REGISTRY_PASSWORD

  echo "## Deploying kapp-controller"
  ./ytt -f ./bundle/kapp-controller/config/ -f ./bundle/registry-creds/ --data-values-env YTT --data-value-yaml kappController.deployment.concurrency=10 \
    | ./kbld -f- -f ./bundle/.imgpkg/images.yml \
    | ./kapp deploy -a kapp-controller -n $ns_name -f- --yes

  echo "## Deploying secretgen-controller"
  ./ytt -f ./bundle/secretgen-controller/config/ -f ./bundle/registry-creds/ --data-values-env YTT \
    | ./kbld -f- -f ./bundle/.imgpkg/images.yml \
    | ./kapp deploy -a secretgen-controller -n $ns_name -f- --yes 
```
{% endraw %}
```section:end
```

Because kapp- and secretgen-controller are already installed in this cluster, you don't have to run the installation script. But for you future installations, as you can see in the script, you have to set some environment variables like the location of the install bundle before you execute the install script.

Let's now check that the Pods of the kapp-controller, and secretgen-controlle are running in our cluster.
```execute 
kubectl get pods -n kapp-controller && kubectl get pods -n secretgen-controller
```

With both running, you can now have a closer look at them after you cleaned up the directory.
```execute 
rm tanzu-cluster-essentials-install.sh
rm tanzu-cluster-essentials-linux-amd64-1.0.0.tgz
rm -rf tanzu-cluster-essentials
```