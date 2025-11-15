HOW TO ONBOARD A USER TO YOUR CLUSTER


1. THEY CREATE A PRIVATE KEY AND A CERTIFICATE \
openssl genrsa -out {file-name} 2048    --->  generate private key \
openssl req -new -key adam.key -out adam.csr -subj "/CN=adam" 

2. YOU GENERATE A CERTIFICATE SIGN IN REQUEST MANIFEST TO YOUR LOCAL CLUSTE CA(certificate authority)

apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: adam
spec:
  request: <BASE64_ENCODED_CSR>  ---> here you have to base64 encode their certificate using ----> cat {cert-file-name} | base64 | tr -d "\n"
  signerName: kubernetes.io/kube-apiserver-client
  usages:
    - digital signature
    - key encipherment
    - client auth

3. YOU CAN DESCRIBE AND CHECK THE REQUEST
kubectl describe csr adam


4. ONCE EVERYTHING IS READY YOU CAN APPROVE AND ISSUE THE CERTIFICATE
kubectl certificate approve adam

5. ACQUIRE THE APPROVED CERTIFICATE

kubectl get csr adam -o yaml  > approved-cert.yaml
***the approved certificate will be base64 encoded so decode it the you will get the certficate
