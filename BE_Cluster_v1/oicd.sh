# author: brian marwa
# email: kidbrion7@gmail.com
# # run cmd: ./oicd.sh

# This script sets up the AWS EBS CSI driver in an Amazon EKS cluster named fleetman. 
# It installs the eksctl CLI, associates an IAM OIDC provider, creates a service account with the necessary permissions, and deploys the EBS CSI driver as an addon. 
# Ensure that the AWS region specified matches your cluster's region and that you have the required IAM permissions. 
# After executing, verify the EBS CSI driver’s status by checking the pods in the kube-system namespace.

#!/bin/bash 


curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl utils associate-iam-oidc-provider --region=eu-west-1 --cluster=BE-cluster-v1 --approve
eksctl create iamserviceaccount \
  --region eu-west-1 \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster BE-cluster-v1 \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole
eksctl create addon --name aws-ebs-csi-driver --cluster BE-cluster-v1 --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole --force