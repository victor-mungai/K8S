# Get CRDS
```
cd ~/K8S/CKA
git clone --depth 1 --branch v2.3.0 https://github.com/nginx/nginx-gateway-fabric.git
cd nginx-gateway-fabric
kubectl apply -k config/crd/gateway-api/standard

```
# Install Gateway Api Resources(Gateway controller, gateway class)
```
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway
```
