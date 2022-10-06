# Deploy airflow locally

## Prerequisites

1. [kind](https://kind.sigs.k8s.io/])
2. helm
3. kubectl

### Create k8s `kind` cluster
```
kind create cluster --name airflow
```
check:
```
kubectl cluster-info --context kind-airflow
```

### Add Airflow Helm Stable Repo
```
helm repo add apache-airflow https://airflow.apache.org
helm repo update
```

### Create namespace
```
export NAMESPACE=example-airflow-namespace
kubectl create namespace $NAMESPACE
```

### Install the chart
```
export RELEASE_NAME=example-airflow-release
helm install $RELEASE_NAME apache-airflow/airflow --namespace $NAMESPACE -f values-local.yaml
```

### Upgrade
```
helm upgrade --install $RELEASE_NAME apache-airflow/airflow --namespace $NAMESPACE -f values-local.yaml
```

### Verify process
```
watch kubectl get all -n example-airflow-namespace
```


### Delete k8s `kind` cluster

```
kind delete cluster --name airflow
```