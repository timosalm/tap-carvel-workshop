set -x

kubectl create ns carvel-workshop-examples

ytt template -f resources -f values.yaml --ignore-unknown-comments | kapp deploy -n tap-install -a tap-carvel-workshop -f- --diff-changes --yes
kubectl delete pod -l deployment=learningcenter-operator -n learningcenter
