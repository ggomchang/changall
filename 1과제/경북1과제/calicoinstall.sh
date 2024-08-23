curl -L https://github.com/projectcalico/calico/releases/download/v3.28.1/calicoctl-linux-amd64 -o calicoctl
chmod +x ./calicoctl
sudo mv ./calicoctl /usr/local/bin/calicoctl

helm repo add projectcalico https://docs.tigera.io/calico/charts
echo '{ installation: {kubernetesProvider: EKS }}' > values.yaml
helm install calico projectcalico/tigera-operator \
  --version v3.28.1 -f values.yaml \
  --namespace tigera-operator --create-namespace

cat << EOF > append.yaml
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - patch
EOF
kubectl apply -f <(cat <(kubectl get clusterrole aws-node -o yaml) append.yaml)

kubectl set env daemonset aws-node -n kube-system ANNOTATE_POD_IP=true

CALICO_POD_NAME=$(kubectl get pods -n calico-system -o name | grep calico-kube-controllers- | cut -d '/' -f 2)
kubectl delete pod $CALICO_POD_NAME -n calico-system

CALICO_POD_NAME=$(kubectl get pods -n calico-system -o name | grep calico-kube-controllers- | cut -d '/' -f 2)
kubectl describe pod $CALICO_POD_NAME -n calico-system | grep vpc.amazonaws.com/pod-ips