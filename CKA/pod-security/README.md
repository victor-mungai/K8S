# Kubernetes Pod Security
# Overview

This document describes how Pod-level security is enforced in Kubernetes using:

Pod Security Standards (PSS)

Namespace security labels

Security contexts

Linux capabilities

Seccomp profiles

These mechanisms help reduce attack surface and enforce least privilege at the workload level.

# 1. Pod Security Standards (PSS)

Kubernetes defines three built-in Pod Security levels:

Level	Description
Privileged	Unrestricted policy, wide permissions
Baseline	Prevents known privilege escalations
Restricted	Enforces strict least-privilege controls

Restricted is recommended for production environments.

Official reference:
https://kubernetes.io/docs/concepts/security/pod-security-standards/

# 2. Namespace Security Labels

Pod Security Admission (PSA) enforces policies via namespace labels.

Example — enforcing restricted policy:
```
kubectl label namespace production \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest
```

Available modes:

enforce → blocks violating pods

audit → logs violations

warn → shows warnings but allows creation

Example with all modes:
```
kubectl label namespace production \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```
# 3. Security Contexts

Security contexts define privilege and access control settings for pods and containers.

They can be set at:

Pod level

Container level

Example:
```
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
spec:
  securityContext:
    runAsNonRoot: true
    fsGroup: 2000
  containers:
    - name: app
      image: nginx
      securityContext:
        allowPrivilegeEscalation: false
        runAsUser: 1000
        readOnlyRootFilesystem: true
```

Key fields:

Field	Purpose
runAsNonRoot	Prevent root execution
runAsUser	Specify UID
allowPrivilegeEscalation	Block privilege escalation
readOnlyRootFilesystem	Prevent filesystem writes
fsGroup	Control shared volume access
# 4. Linux Capabilities

Containers inherit Linux capabilities by default. These should be minimized.

Drop all capabilities:
```
securityContext:
  capabilities:
    drop:
      - ALL
```

Add only required capabilities:
```
securityContext:
  capabilities:
    add:
      - NET_BIND_SERVICE
```

Best practice:

Drop ALL

Add back only what is strictly required

# 5. Seccomp Profiles

Seccomp restricts system calls available to containers.

Recommended: RuntimeDefault

Example:
```
securityContext:
  seccompProfile:
    type: RuntimeDefault
```

Other options:

Type	Description
RuntimeDefault	Default container runtime profile
Localhost	Custom profile from node
Unconfined	No syscall filtering (not recommended)

Example using custom profile:
```
securityContext:
  seccompProfile:
    type: Localhost
    localhostProfile: profiles/custom-seccomp.json
```
# 6. Recommended Secure Pod Template
```
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
spec:
  securityContext:
    runAsNonRoot: true
  containers:
    - name: app
      image: nginx
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
        seccompProfile:
          type: RuntimeDefault
```
# 7. Security Best Practices

Enforce restricted Pod Security Standard

Always run containers as non-root

Drop all Linux capabilities by default

Use RuntimeDefault seccomp profile

Avoid privileged containers

Avoid hostPath mounts unless absolutely necessary

Use read-only root filesystems

# 8. Validation

Check namespace labels:
```
kubectl get ns --show-labels
```

Test enforcement:
```
kubectl run test --image=nginx --restart=Never
```

If restricted policy is active, insecure pods will be rejected.

# Conclusion

Kubernetes pod security relies on:

Namespace-level enforcement

Container-level security context configuration

Reduced capabilities

System call filtering via seccomp

When combined, these controls significantly reduce the risk of container breakout and privilege escalation.
