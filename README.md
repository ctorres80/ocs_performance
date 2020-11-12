# Synthetic benchmarking tool for OpenShift Container Storage for block and file interfaces

## Introduction 
This is in an interactive ansible role for performance testing with synthetic benchmarking workloads, the purpose is to simulate different workload profiles based on your inputs.

## Requirements
- OpenShift Container Platform v4.2+ 
- OpenShift Container Storage v4.2+ (AKA OCS)
- Supported infrastructures: AWS IPI, VMware UPI (Other platforms have not been tested yet but the tool should work)
- OpenShift management node with admin serviceaccount
- `oc` client with kubeconfig file authentication
- `git` client
- Ansible at least v2.8 

## Workflow
The ansible role will automate following workflow:
- It will deploy a 2 Statefulsets:
    - 1 Statefulset with fio container that will consume block with ceph-rbd interface in OCS
    - 1 Statefulset with fio container that will consume file with cephfs interface in OCS


## Testing environment
Following the Openshift cluster information 
```bash
[ctorres-redhat.com@bastion ~]$ oc version
Client Version: 4.5.7
Server Version: 4.6.3
Kubernetes Version: v1.19.0+9f84db3
```
In bold the OCS nodes (following labels work with AWS IPI deployment)

    [ctorres-redhat.com@bastion machinesets]$ oc get nodes -L kubernetes.io/hostname -L node.kubernetes.io/instance-type -L failure-domain.beta.kubernetes.io/region -L failure-domain.beta.kubernetes.io/zone
    NAME                                            STATUS   ROLES    AGE   VERSION           HOSTNAME          INSTANCE-TYPE   REGION         ZONE
    ``ip-10-0-140-220.eu-central-1.compute.internal   Ready    worker   72s   v1.19.0+9f84db3   ip-10-0-140-220   i3.16xlarge     eu-central-1   eu-central-1a``
    ip-10-0-145-177.eu-central-1.compute.internal   Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-145-177   m5.4xlarge      eu-central-1   eu-central-1a
    ip-10-0-151-216.eu-central-1.compute.internal   Ready    master   12h   v1.19.0+9f84db3   ip-10-0-151-216   c5d.2xlarge     eu-central-1   eu-central-1a
    ip-10-0-182-17.eu-central-1.compute.internal    Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-182-17    m5.4xlarge      eu-central-1   eu-central-1b
    ip-10-0-183-7.eu-central-1.compute.internal     Ready    worker   74s   v1.19.0+9f84db3   ip-10-0-183-7     i3.16xlarge     eu-central-1   eu-central-1b
    ip-10-0-186-76.eu-central-1.compute.internal    Ready    master   12h   v1.19.0+9f84db3   ip-10-0-186-76    c5d.2xlarge     eu-central-1   eu-central-1b
    ip-10-0-192-170.eu-central-1.compute.internal   Ready    master   12h   v1.19.0+9f84db3   ip-10-0-192-170   c5d.2xlarge     eu-central-1   eu-central-1c
    ip-10-0-212-27.eu-central-1.compute.internal    Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-212-27    m5.4xlarge      eu-central-1   eu-central-1c
    ip-10-0-213-116.eu-central-1.compute.internal   Ready    worker   69s   v1.19.0+9f84db3   ip-10-0-213-116   i3.16xlarge     eu-central-1   eu-central-1c

Following my OCS node configuration
```bash
[ctorres-redhat.com@bastion machinesets]$ oc get nodes -l cluster.ocs.openshift.io/openshift-storage=  -o=custom-columns=NAME:.metadata.name,CPU:.status.capacity.cpu,RAM:.status.capacity.memory
NAME                                            CPU   RAM
ip-10-0-140-220.eu-central-1.compute.internal   64    503586776Ki
ip-10-0-183-7.eu-central-1.compute.internal     64    503586776Ki
ip-10-0-213-116.eu-central-1.compute.internal   64    503587072Ki
```