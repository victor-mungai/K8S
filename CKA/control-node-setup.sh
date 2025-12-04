#!/bin/bash
set -e # Exit immediately if a command fails

echo "--- Kubernetes Control Plane Setup Script ---"

# --- Progress Spinner Function ---
start_spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='/-\|'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r$1 %c " "$spinstr"
        local spinstr=$temp${spinstr%???}
        sleep $delay
    done
    printf "\r$1 Done.\n"
}

# 1. Disable Swap (Required for K8s)
echo -n "Disabling Swap..."
swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo " Done."

# 2. Configure Kernel Modules & Sysctl parameters (Required for K8s Networking)
echo "Forwarding IPv4 and letting iptables see bridged traffic..."
(
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system > /dev/null
) &
start_spinner "Configuring Kernel Settings"

# Verify that the br_netfilter, overlay modules are loaded
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify that the net.bridge... variables are set
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# 3. Install and Configure Containerd (Runtime)
echo "Installing and configuring Containerd..."
(
sudo apt-get update -y
sudo apt-get install -y containerd runc
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl restart containerd
) &
start_spinner "Installing Containerd"

# Check that containerd service is up and running
systemctl status containerd | grep Active

# 4. Install CNI Plugins (via package manager for simplicity, though manual curl works too)
echo "CNI plugins are typically managed by the CNI manifest applied later (e.g. Calico/Weave)."

# 5. Install kubeadm, kubelet and kubectl (K8s Components)
echo "Installing kubeadm, kubelet, and kubectl (v1.29.6)..."
(
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg > /dev/null

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

sudo apt-get update > /dev/null
# Use specific versions as requested in the original script
sudo apt-get install -y kubelet=1.29.6-1.1 kubeadm=1.29.6-1.1 kubectl=1.29.6-1.1 --allow-downgrades --allow-change-held-packages > /dev/null
sudo apt-mark hold kubelet kubeadm kubectl
) &
start_spinner "Installing Kubernetes Binaries"

# 6. Verification
echo "Verification complete. Component versions:"
kubeadm version
kubelet --version
kubectl version --client
sudo crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock
echo "--- Script finished. Next step: Run 'sudo kubeadm init' ---"

