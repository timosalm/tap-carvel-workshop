##### kbld - Image solver for your configuration

kbld (pronounced: kei·bild) seamlessly incorporates image building, pushing, and resolution into your development and deployment workflows. Result is configuration with immutable image references.

**Features**
- **Immutable image references:** Resolves image references to their digest (immutable) form
- **Delegates building to proven tools:** Orchestrates image builds (delegates to tools like Docker, pack, kubectl-buildkit) and registry pushes
- **Saves sources of built images:** Records metadata about image sources in annotation on Kubernetes resources

###### Resolving image references to digests
Docker images can be referenced by their name (nginx), name-tag pair (nginx:1.14), or a digest (nginx@sha256:c398dc3f2...). One can avoid potential deployment inconsistencies by using digest references as they are immutable, and therefore always points to an exact image.

Here you can see very basic example of Pod with a nginx container.
```terminal:execute
command: kubectl run nginx --image nginx --dry-run=client -o yaml
clear: true
```

With kbld you are able to resolve the image reference to its full digest form.
```terminal:execute
command: kubectl run nginx --image nginx --dry-run=client -o yaml | kbld -f-
clear: true
```

In some cases recording resolution results via the **--lock-output** flag may be useful.
```terminal:execute
command: kubectl run nginx --image nginx --dry-run=client -o yaml | kbld --lock-output kbld.lock.yml -f-
clear: true
```

```editor:open-file
file: kbld.lock.yml
```

Lock content can be used via -f to produce the same resolved configuration.
```terminal:execute
command: kubectl run nginx --image nginx --dry-run=client -o yaml | kbld -f kbld.lock.yml -f-
clear: true
```

With the **--imgpkg-lock-output** flag, kbld creates an ImagesLock file that can be used as input for the packaging and distribution tool **imgpkg**, and can also be used via -f to produce the same resolved configuration.
```terminal:execute
command: kubectl run nginx --image nginx --dry-run=client -o yaml | kbld --imgpkg-lock-output imgpkg.lock.yml -f-
clear: true
```

```editor:open-file
file: "imgpkg.lock.yml"
```

```terminal:execute
command: kubectl run nginx --image nginx --dry-run=client -o yaml | kbld -f imgpkg.lock.yml -f-
clear: true
```

###### Building images from source

kbld can be used to **orchestrate build tools such as Docker and pack to build images from source and record resulting image reference in a YAML file**. This is especially convenient during local development when working with one or more changing applications.

To demonstrate this feature, you will use the examples provided with the tool.
```terminal:execute
command: git clone https://github.com/vmware-tanzu/carvel-kbld.git
clear: true
```

```editor:open-file
file: carvel-kbld/examples/simple-app-build-local/build.yml
```

Running above example will start two docker build processes and produce following output.
```terminal:execute
command: |-
  cd carvel-kbld
  kbld -f examples/simple-app-build-local/build.yml
  cd ..
clear: true
```

You should be able to see the resulting **image references and metadata about the image sources in the annotations**.

As long as the building tool has proper push access (run docker login for Docker), **kbld can push out built images to specified repositories** as you can see in the example here. 
```editor:open-file
file: carvel-kbld/examples/simple-app-build-and-push/build.yml
```

##### imgpkg - Bundle your bits with guaranteed immutability

imgpkg is a tool that allows users to **store a set of arbitrary files as an OCI image**. One of the driving use cases is to store Kubernetes configuration (plain YAML, ytt templates, Helm templates, etc.) in OCI registry as an image.

imgpkg’s primary concept is a **bundle**, which is an OCI image that holds 0+ arbitrary files and 0+ references to dependent OCI images (which may also be bundles). With this concept, imgpkg is able to copy bundles and their dependent images across registries (both online and offline).

To demonstrate this feature, you will use the examples provided with the tool.
```terminal:execute
command: |-
    git clone https://github.com/vmware-tanzu/carvel-imgpkg
    find ./carvel-imgpkg -type f -a \( -name "*.yaml" -o -name "*.yml"  \) -a -exec sed -i '/namespace: /d' {} +;
clear: true
```

Let's use this example of a Deployment with a Service to create a imgpkg bundle.
```editor:open-file
file: carvel-imgpkg/examples/basic-step-1/config.yml
```

The config.yml file contains a very simple Kubernetes application. Your application may have as many configuration files as necessary in various formats such as plain YAML, ytt templates, Helm templates, etc.

In our example, config.yml includes an image reference to docker.io/dkalinin/k8s-simple-app. This reference does not point to an exact image (via digest) meaning that it may change over time. To ensure you get precisely the bits you expect, it will lock it down to an exact image via **kbld**. 
```terminal:execute
command: mkdir carvel-imgpkg/examples/basic-step-1/.imgpkg
clear: true
```
```terminal:execute
command: kbld --imgpkg-lock-output carvel-imgpkg/examples/basic-step-1/.imgpkg/images.yml -f carvel-imgpkg/examples/basic-step-1/config.yml
clear: true
```

```editor:open-file
file: carvel-imgpkg/examples/basic-step-1/.imgpkg/images.yml
```

You can also add an optional bundle.yml which records informational metadata to your .imgpkg/ directory.
```execute
cat <<EOF > carvel-imgpkg/examples/basic-step-1/.imgpkg/bundle.yml
apiVersion: imgpkg.carvel.dev/v1alpha1
kind: Bundle
metadata:
  name: basic
authors:
- name: Carvel Team
  email: carvel@vmware.com
websites:
- url: carvel.dev/imgpkg
EOF
```

```editor:open-file
file: carvel-imgpkg/examples/basic-step-1/.imgpkg/bundle.yml
```

###### Pushing the bundle to a registry
Let's now authenticate with our registry and push the bundle to it registry.
```terminal:execute
command: docker login $CONTAINER_REGISTRY_HOSTNAME -u $CONTAINER_REGISTRY_USERNAME -p $CONTAINER_REGISTRY_PASSWORD
clear: true
```
```terminal:execute
command: imgpkg push -b ${CONTAINER_REGISTRY_HOSTNAME}/tap-carvel-workshop-examples/simple-app-bundle:v1.0.0 -f carvel-imgpkg/examples/basic-step-1
clear: true
```

###### Pulling the bundle from registry
Now that you have pushed a bundle to a registry, other users can pull it.
```terminal:execute
command: imgpkg pull -b ${CONTAINER_REGISTRY_HOSTNAME}/tap-carvel-workshop-examples/simple-app-bundle:v1.0.0 -o simple-app-bundle
clear: true
```

```editor:open-file
file: simple-app-bundle/config.yml
```

If imgpkg had been able to find all images that were referenced in the ImagesLock configuration in the registry where bundle is located, then it would update .imgpkg/images.yml file to point to the registry-local locations.

###### Use pulled bundle contents 
Now that you have have pulled bundle contents to a local directory, you can deploy the Kubernetes configuration.

Before you apply the Kubernetes configuration, let’s use kbld to ensure that the Kubernetes configuration uses exact image reference from .imgpkg/images.yml.
```terminal:execute
command: kbld -f simple-app-bundle/config.yml -f simple-app-bundle/.imgpkg/images.yml | kubectl apply -f-
clear: true
```

###### Copy a bundle between registries
To ensure that your Kubernetes application does not rely on images from external registries when deployed or that all images are consolidated into a single registry, even if that registry is not air-gapped, you can use the **imgpkg copy** command to copy a bundle between registries.
```terminal:execute
command: imgpkg copy -b ${CONTAINER_REGISTRY_HOSTNAME}/tap-carvel-workshop-examples/simple-app-bundle:v1.0.0 --to-repo ${CONTAINER_REGISTRY_HOSTNAME}/tap-carvel-workshop-examples/copied-simple-app-bundle
clear: true
```
If you don't have location from which you are able to connect to both registries, there is an option to export/import a tarball.
```execute
imgpkg copy -b ${CONTAINER_REGISTRY_HOSTNAME}/tap-carvel-workshop-examples/simple-app-bundle:v1.0.0 --to-tar my-image.tar
imgpkg copy --tar my-image.tar --to-repo ${CONTAINER_REGISTRY_HOSTNAME}/tap-carvel-workshop-examples/copied-simple-app-tar-bundle
```

If you pull the bundle from the destination registry, you should be able to see that the .imgpkg/images.yml file was updated with the destination registry locations of the images. This happened because, in the prior step, the images referenced by the bundle were copied into the destination registry.
```terminal:execute
command: imgpkg pull -b ${CONTAINER_REGISTRY_HOSTNAME}/tap-carvel-workshop-examples/copied-simple-app-tar-bundle:v1.0.0 -o copied-simple-app-tar-bundle
clear: true
```

```editor:open-file
file: copied-simple-app-tar-bundle/.imgpkg/images.yml
```

###### Automation Workflow
When using an automated CI tool you might want to promote a given Bundle between steps of the pipeline. This is supported by a **BundleLock** configuration which stores a digest reference to a bundle (as well as the tag it was pushed with). This configuration is generated by the **--lock-output** flag during a push command. You can reference it with the imgpkg pull and copy command via the **--lock** flag.

#### vendir - Declaratively state directory's contents

vendir allows to declaratively state what should be in a directory. It was designed to easily manage libraries for ytt; however, it is a generic tool and does not care how files within managed directories are used.

Let's create a vendir.yml and see it in action.
```execute
mkdir vendir-demo
cat <<EOF > vendir-demo/vendir.yml
apiVersion: vendir.k14s.io/v1alpha1
kind: Config
directories:
- path: config/_ytt_lib
  contents:
  - path: app
    git:
      url: https://github.com/vmware-tanzu/carvel-ytt-library-for-kubernetes
      ref: origin/develop
    newRootPath: app
EOF
```

```editor:open-file
file: vendir-demo/vendir.yml
```

By executing the following command, vendir downloads the specified assets.
```terminal:execute
command: vendir sync --chdir vendir-demo
clear: true
```

Let's examine what vendir placed into our directory.
```terminal:execute
command: tree vendir-demo
clear: true
```

In addition to git, vendir supports the following sources for fetching:
- hg (Mercurial)
- http
- image (image from OCI registry)
- imgpkgBundle (bundle from OCI registry)
- githubRelease
- helmChart
- directory

#### Clean up
Execute the following command to clean up the directory.
```execute
rm -rf carvel-imgpkg imgpkg.lock.yml kbld.lock.yml carvel-kbld copied-simple-app-tar-bundle my-image.tar copied-simple-app-bundle simple-app-bundle vendir-demo
kubectl delete service simple-app
kubectl delete deployment simple-app
```