# Kubernetes RBAC & User Authentication Guide

This document explains how to verify Kubernetes permissions, create RBAC roles, bind them to users, and configure user authentication in your kubeconfig.

---

## 🧩 Check User Identity

```
kubectl auth whoami
```
🔐 Check Permissions
Check what your current user can do:

```
kubectl auth can-i get pods
```
Check what another user can do:


```kubectl auth can-i get pods --as <user-name>```
🛠 Create a Role
A Role defines what actions are allowed within a namespace.

Example: create a role with read-only access to pods:

```
kubectl create role <role-name> \
  --verb=get --verb=list --verb=watch \
  --resource=pods
```
🔗 Create a RoleBinding
Assign a role to a user:

```
kubectl create rolebinding <rolebinding-name> \
  --role=<role-name> \
  --user=<user-name>
```
This grants the user the permissions defined in the role.

🔑 Configure User Credentials
Add a new user to your kubeconfig using a client certificate and key:

```
kubectl config set-credentials <user-name> \
  --client-certificate=<path-to-user-certificate> \
  --client-key=<path-to-user-key> \
  --embed-certs=true
--embed-certs=true
```
stores the certificate and key directly in the kubeconfig.

🌐 Configure a Context for the User
Create a context linking the user and cluster:

```
kubectl config set-context <context-name> \
  --cluster=<cluster-name> \
  --user=<user-name>
```
Switch to the context:
```
kubectl config use-context <context-name>
```
✅ Summary Workflow
Create a Role

Create a RoleBinding

Set user credentials

Create context

Switch context

Verify with
```kubectl auth can-i```

