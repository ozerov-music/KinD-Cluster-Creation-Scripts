#!/bin/bash

# Create 3-node Cluster
echo "Creating Kind Cluster using configuration in cluster-conf"
kind create cluster --name miniK3 --config cluster-conf/kind-4nodes.yaml

echo -e "\nGetting Kubernetes Dashboard ..."

# Get Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc6/aio/deploy/recommended.yaml

echo -e "\nCreating Service Accounts and Cluster Role Binding"

# Create a new ServiceAccount
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

# Create a ClusterRoleBinding for the ServiceAccount
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

# Get Login Token
echo -e "\nGetting Login:\n"
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') | grep token > dashboard-token.secret
cat dashboard-token.secret

# Set up elasticsearch, fluent-bit, and kibana
echo -e "\nSetting up EFK Stack . . ."
. cluster-conf/setup-efk-stack.bash

echo -e "\nSetup completed! Please proceed to port-forwarding your applications to gain access."
