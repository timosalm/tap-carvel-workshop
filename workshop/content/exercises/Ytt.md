**ytt** is a tool that can templatize, combine, and patch any YAML content. 

To ge familiar with the capabilities of ytt, you will use the examples provided with the tool.
```terminal:execute
command: git clone https://github.com/vmware-tanzu/carvel-ytt
clear: true
```

##### Usage
You can execute ytt by running the command on **individual files** or a **directory of files**. 
It will build the configuration and write it to STDOUT by default.
Run the following command to see an example with a plain YAML file.
```terminal:execute
command: ytt -f carvel-ytt/examples/playground/basics/example-plain-yaml
clear: true
```

##### Directives and Annotations
ytt uses **YAML comments for ytt annotations and ytt directives** and a slightly modified version of the **Starlark programming language** which is a dialect of Python. An example for an annotation is `# @data/values` and for directives, `#@ if`, and `#@ load`.

##### Types and Control Flow
When you need to process data, **declaring data using ytt directives** instead of plain YAML nodes can be helpful. ytt will convert these values to their respective YAML types.
```editor:open-file
file: carvel-ytt/examples/playground/basics/example-datatypes/datatypes.yml
line: 1
```
```terminal:execute
command: ytt -f carvel-ytt/examples/playground/basics/example-datatypes/datatypes.yml
clear: true
```

The ytt language reference shows the **standard methods** you can use **on strings and collections**. And it details the **if statement, for-loop, and function control-flow structures**.
```editor:open-file
file: carvel-ytt/examples/playground/basics/example-if/if.yml
line: 1
```
```editor:open-file
file: carvel-ytt/examples/playground/basics/example-for/for.yml
line: 1
```

##### Variables, Functions, and Fragments
Here you can see what the **syntax of variables, functions, and fragments** is and how you can use them.
```editor:open-file
file: carvel-ytt/examples/playground/getting-started/example-extract-yaml-fragments/config.yml
line: 1
```

Let's now run the example to see the output. 
```terminal:execute
command: ytt -f carvel-ytt/examples/playground/getting-started/example-extract-yaml-fragments/config.yml
clear: true
```

##### The Load directive
The `#@ load` directive is used to load functions from other libraries. These could be built-in modules or ones you define in another file.

```editor:open-file
file: carvel-ytt/examples/playground/basics/example-load/config.yml
line: 1
```

##### Overlays
An overlay allows you to patch YAML structures. By patching, you could use it for matching, inserting, replacing, removing items, etc. 

Let's have a look at the files of the following example ...
```editor:open-file
file: carvel-ytt/examples/playground/basics/example-overlay-files/config1.yml
line: 1
```

... and run it to see the output.
```terminal:execute
command: ytt -f carvel-ytt/examples/playground/basics/example-overlay-files
clear: true
```

##### Data Values and Schema
The data module, `#@ load("@ytt:data", "data")`, can be used to pass in data that is defined in other files, also in combination with a schema module, `#@data/values-schema`

Let's have a look at the files of the following example and run it to see the output.
```editor:open-file
file: carvel-ytt/examples/k8s-add-global-label/config.yml
line: 1
```

```terminal:execute
command: ytt -f carvel-ytt/examples/k8s-add-global-label
clear: true
```

You can also override the default value via the `-v` argument
```terminal:execute
command: ytt -f carvel-ytt/examples/k8s-add-global-label -v build_num=123
clear: true
```

##### Deploying to Kubernetes
ytt is purely a configuration tool that just outputs YAML files, but doesn’t apply or run them. 
In order to deploy our applications to Kubernetes, you need to use tools like kubectl or **kapp** (also part of the Carvel tool suite) with the output from ytt.

You can apply the ytt output via kubectl with and have a look at the deployed resources.
```terminal:execute
command: ytt -f carvel-ytt/examples/playground/basics/example-demo | kubectl apply -f-
clear: true
```
```terminal:execute
command: kubectl get pod,service
clear: true
```

It's also possible to redirect the output of ytt to a file. 

Execute the following command to clean up the directory.
```execute
ytt -f carvel-ytt/examples/playground/basics/example-demo | kubectl delete -f-
rm -rf carvel-ytt
clear
```