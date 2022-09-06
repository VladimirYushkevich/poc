# Deploy kafka on k8s cluster locally

## Prerequisites

1. [kind](https://kind.sigs.k8s.io/])
2. helm
3. kubectl

### Prepare k8s cluster

* Start `kind` k8s cluster(with minimal settings for Ingress) and create `kafka` cluster:

```
kind create cluster --name kafka --config=local/kind-config.yaml
```

* Enable Ingress Controller (NGINX). It will be needed for `kafka-bridge` component:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

check:

```
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

### Create kafka cluster and components

* Create kafka `cluster` (takes some time, ~ min):

```
helm upgrade --install my-kafka charts/kafka -n kafka --create-namespace -f charts/kafka/values-local.yaml
```

### Verify that cluster is operational

* check `kafka-cluster-operator`:

```
kubectl wait --namespace kafka \
  --for=condition=ready pod \
  --selector=strimzi.io/kind=cluster-operator \
  --timeout=240s
```

* check `zookeeper`:

```
kubectl wait --namespace kafka \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=zookeeper \
  --timeout=120s
```

* check `kafka`:

```
kubectl wait --namespace kafka \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=kafka \
  --timeout=120s
```

* check `kafka-bridge`:

```
kubectl -n kafka describe service my-kafka-bridge-bridge-service
```

* check `entity-operator`:

```
kubectl wait --namespace kafka \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=entity-operator \
  --timeout=240s
```

* check `kafka-topic`:

```
kubectl wait --namespace kafka \
    --for=condition=ready KafkaTopic \
    --selector=name=key-mouse-event \
    --timeout=10s
```

* check `ingress-rules`:

```
curl -v http://localhost/topics | jq
```

### Send and receive messages

* via broker's endpoint (requires kafka specific library, implemented in `kafka-console-producer.sh`):

```
kubectl -n kafka run kafka-producer \
    -it --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 \
    --rm=true \
    --restart=Never \
    -- bin/kafka-console-producer.sh \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 \
    --topic test
```

```
kubectl -n kafka run kafka-consumer \
    -it --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 \
    --rm=true --restart=Never \
    -- bin/kafka-console-consumer.sh \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 \
    --topic test \
    --from-beginning
```

* via `kafka-bridge`:

```
curl -X POST \
  http://localhost/topics/test \
  -H 'content-type: application/vnd.kafka.json.v2+json' \
  -d '{
    "records": [
        {
            "key": "key-1",
            "value": "value-1"
        },
        {
            "key": "key-2",
            "value": "value-2"
        }
    ]
}'
```

### Delete `kind` cluster

```
kind delete cluster --name kafka
```