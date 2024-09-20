# Istio

## Aim

The aim of this project is to install Istio on a kubernetes cluster and deploy a simple application to test the
installation.
The application is composed of three microservices that communicate with each other. Some of the services have issues.
The orders service forwards all the headers that start with "x-" to the other services.
The goal is to use Istio to manage the traffic between the services and to apply some policies to manage the issues.

## Infrastructure/Helm project

This project install three microservices:

- orders
- products
- customers

All services are exposes by an ingress gateway. Endpoints:

- orders service:
    - /api/v1/orders/
    - /api/v1/raw-orders/
- customers service:
    - /customers
    - /customer/:customer_id/surname
    - /customer/:customer_id/name
- products service:
    - /api/v1/products
    - /api/v1/products/:productId/price
    - /api/v1/products/:productId/name

The endpoint /api/v1/orders/ returns a list of orders enriched with the customer name and surname and the product name
and price.
The service uses the other two services to enrich the data.

The helm chart installs three different versions of the customer service (Canary deployment):

- V1: works correctly
- V2: responds with a very long response time
- V3: raises always an error

## Demo

### Requirements

- Cluster kubernetes
    - nginx controller already installed (default ingressClassName: nginx)
- Helm
- kubectl
- istioctl

### Install Istio

```bash
# Istio
istioctl install --set profile=demo --set meshConfig.defaultConfig.tracing.zipkin.address="jaeger-collector.istio-system:9411"
# Kiali - Service Mesh Observability
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/addons/kiali.yaml
# Prometheus - Metrics
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/addons/prometheus.yaml
# Jaeger - Distributed Tracingkubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/addons/jaeger.yaml

```

NOTE: The demo profile is used to install the default configuration of Istio. The demo profile has low resource
requirements, see [Istio documentation](https://istio.io/latest/docs/setup/additional-setup/config-profiles/) for more
information.

### Create namespace and add istio-injection label

The istio-injection label is used to enable the automatic sidecar injection.
If some pod is already running in the namespace before the label is added, the sidecar will be injected when the pod is
restarted.
For more information see [Istio documentation](https://istio.io/latest/docs/setup/install/istioctl/).

```bash
kubectl create namespace istio-demo
kubectl label namespace istio-demo istio-injection=enabled
```

### Install the helm chart

```bash
helm upgrade --install -n orders istio-example .
```

### Open the /api/v1/orders/ endpoint

Retrieve the ingress gateway IP and open the endpoint /api/v1/orders/ in the browser.

```bash
http://{YOUR GATEWAY IP}/api/v1/orders/
```

Reload the page multiple times to see the different responses. You can also see the responses in the browser console.

### Open dashboards

Kiali and Jaeger are installed by default with the demo profile. These dashboards are useful to monitor the traffic and
the performance of the services.

```bash
istioctl dashboard kiali
istioctl dashboard jaeger
```

### Play with istio

- Find the service that has the delay issue
    - Configure a timeout on the service
- Move all the traffic to the V1 version of the customer service
  - mirror the traffic to the V3 version of the customer service
- Configure a retry policy
- Use headers to route the traffic to the V2 version of the customer service
- Fault injection

### Other features
- Traffic policy
  - loadbalancer/session affinity (not compatible with traffic shifting)
- Ingress Gateway (instead of ingress controller)
- Circuit breaker
  -  max number of connections
  -  max number of pending requests
  -  max number of errors before breaking
  