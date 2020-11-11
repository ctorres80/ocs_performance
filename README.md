# Synthetic benchmarking tool for OpenShift Container Storage for block and file interfaces

## Introduction 
The following ansible role can help you to automate performance benchmarking to OpenShift Container Storage.
This is in an interactive playbook for synthetic benchmarking workloads that covers different workload profiles based on what you're interesting to test.

## Requirements
- OpenShift v4.2+ 
- OpenShift Container Storage v4.2+ (AKA OCS)
- Supported infrastructures: AWS IPI, VMware UPI (Other platforms have not been tested yet but it should works because there not dependencies)
- OpenShift management node with admin serviceaccount
- oc client and authentication with kubeconfig file

## What this playbook can do for you?
The role will automate following workflow:
- It will deploy a 2 Statefulsets:
    - 1 Statefulset with fio container that will consume block with ceph-rbd interface in OCS
    - 1 Statefulset with fio container that will consume file with cephfs interface in OCS
- Create a dedicated rbd images in the format rbd_name_{{ ansible_hostname }}
- Run "rbd bench" in parallel from each client
- The "rbd bench" statistics are reported in the standard output you can redirect to file for further analysis
- Multiple workload and profiles are supported in this role: :
  - profile: sequential, random
  - type: write, read, rw 
  - block size: 4K, 8K, 16K, 32K, 64K, 128K, 256K, 512K, 1024K, 2048K, 4096K
  - file size: XXXG  (XXX is the size of amount of data to transfer) 


## Testing environment
Following the Openshift cluster information 
```bash
[ctorres-redhat.com@bastion ~]$ oc version
Client Version: 4.5.7
Server Version: 4.6.3
Kubernetes Version: v1.19.0+9f84db3

[ctorres-redhat.com@bastion tools]$ oc get nodes -L kubernetes.io/hostname -L node.kubernetes.io/instance-type -L failure-domain.beta.kubernetes.io/region -L failure-domain.beta.kubernetes.io/zone
NAME                                            STATUS   ROLES    AGE   VERSION           HOSTNAME          INSTANCE-TYPE   REGION         ZONE
ip-10-0-145-177.eu-central-1.compute.internal   Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-145-177   m5.4xlarge      eu-central-1   eu-central-1a
ip-10-0-151-216.eu-central-1.compute.internal   Ready    master   12h   v1.19.0+9f84db3   ip-10-0-151-216   c5d.2xlarge     eu-central-1   eu-central-1a
ip-10-0-182-17.eu-central-1.compute.internal    Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-182-17    m5.4xlarge      eu-central-1   eu-central-1b
ip-10-0-186-76.eu-central-1.compute.internal    Ready    master   12h   v1.19.0+9f84db3   ip-10-0-186-76    c5d.2xlarge     eu-central-1   eu-central-1b
ip-10-0-192-170.eu-central-1.compute.internal   Ready    master   12h   v1.19.0+9f84db3   ip-10-0-192-170   c5d.2xlarge     eu-central-1   eu-central-1c
ip-10-0-212-27.eu-central-1.compute.internal    Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-212-27    m5.4xlarge      eu-central-1   eu-central-1c
```