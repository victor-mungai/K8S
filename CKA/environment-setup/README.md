# Configuring the Control Plane Node IP in Kubernetes

By default, kubelet picks the first non-loopback interface as the node's `InternalIP`. In Vagrant/VirtualBox setups with NAT and bridged adapters, this often causes the node to register the NAT IP (e.g., `10.0.2.15`) instead of the bridged IP. This results in `NotReady` status and inefficient inter-nodee communication.

## Solution ;Force kubelet to use a specific node IP
Create or edit the kubelet configuration file /etc/default/kubelet:
```
KUBELET_EXTRA_ARGS="--node-ip=(the node ip)"

```
Then reload and restart kubelet:
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```
