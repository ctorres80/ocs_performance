# Summary
- [Introduction](#Introduction)
- [LAB Requirements](#Requirements)
- [Performance testing](#performance-testing)
- [OpenShift Data Foundation v4.7](#OpenShift-Data-Foundation-v47)
   -  [Order your lab environment from RHPDS](#Order-your-lab-environment-from-RHPDS)
   -  [Ansible role taks required](#Ansible-role-taks-required)

## Introduction 
This is in an interactive ansible role for performance testing with synthetic benchmarking workloads, the purpose is to simulate different workload profiles based on your inputs for BLock, File and S3 OBC in OpenShift Data Foundation.  
The ansible role includes OpenShift Data Foundation v4.7 Operator deployment and infrastructure provisioning for testing Metro stretched cluster.  
If you already deployed an ODF cluster you can move to [Performance testing](#performance-testing)

## Requirements
- OpenShift Container Platform v4.3+ 
- OpenShift Container Storage v4.3+ (AKA OCS and now ODF)
- OpenShift authentication through kubeconfig file, modifify the following variable accordingly:
```bash
roles/rbd_ceph_performance/defaults/main.yml
# kubeconfig path
kubeconfig: '$HOME/.kube/config'
```

- Supported infrastructures: AWS IPI, VMware UPI (Other platforms have not been tested yet but the tool should work)
- OpenShift management node with admin serviceaccount
- `oc` client with kubeconfig file authentication
- `git` client
- Ansible at least v2.8 

## Performance testing
### Just click on the image below ;)
[![Watch the video](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/video_picture.png)](https://youtu.be/KssJ35seKWU)



## OpenShift Data Foundation v4.7
The OpenShift Data Foundation deployment is based on version 4.7 (RC), the ODF operator container image is:  
`image: quay.io/rhceph-dev/ocs-registry:latest-4.7` 
### Order your lab environment from RHPDS
![Order the lab from RHPDS](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/1.png)
### Ansible role taks required
![The following tasks must be used](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/2.png)
  
  
`# 6 -> Install ODF v4.7 RC operator (tag latest-4.7)                                      #`  
![Install ODF v4.7 RC operator](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/3.png)
- Replace the token authentication secret to allow access to `ocs-registry:latest-4.7`
- Waiting for 5 mins, you can monitor what's happening with:  
```bash
watch oc get nodes
```
- Install the ODF v4.7 Operator from template `roles/rbd_ceph_performance/templates/odfv47.yml`
- If everything has been completed successfully you will see that the OCS Operator version 4.7 will be available 
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/4.png)


`# 7 -> DEPLOY STRETCHED CLUSTER VMs: 3 AZs, Replica-4 (2 OSD nodes in 2 AZ + arbiter)     #`
Please check that you're in this condition before start:    
```bash
oc get machineset -n openshift-machine-api
```
```
NAME                                   DESIRED   CURRENT   READY   AVAILABLE   AGE
cluster-c1f4-kpw7v-worker-eu-west-1a   1         1         1       1           8d
cluster-c1f4-kpw7v-worker-eu-west-1b   1         1         1       1           8d
cluster-c1f4-kpw7v-worker-eu-west-1c   1         1         1       1           8d
```
Select the option #7  
The tasks will take cluster configuration and automatically create the yaml for ocs machinesets. The final result will be 3 new machinesets:
- all the vms are using instance type: m5.4xlarge
- 2 vms will be create in AZ with label `datacenter1`
- 2 vms will be create in AZ with label `datacenter2`
- Each of the above instances are configured to use 4TB EBS volume that will be partioned with 2x2TB partitions
- 1 vms will be deployed in a 3rd AZ with label `arbiter`

There will be a pause of 6 mins, just the time to get the new instances up&running  
```
TASK [rbd_ceph_performance : Pause for 6 minutes to provisioning machines] *******************************************************************************
Tuesday 11 May 2021  15:22:34 +0000 (0:00:02.585)       0:11:29.471 ***********
Pausing for 360 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
```

You can open a new shell and verify if the new machinesets and machines are privisioned/running
```bash
watch oc get machines -n openshift-machine-api
```
```
NAME                                         PHASE         TYPE         REGION      ZONE         AGE
cluster-c1f4-kpw7v-master-0                  Running	   m5.2xlarge   eu-west-1   eu-west-1a   8d
cluster-c1f4-kpw7v-master-1                  Running	   m5.2xlarge   eu-west-1   eu-west-1b   8d
cluster-c1f4-kpw7v-master-2                  Running	   m5.2xlarge   eu-west-1   eu-west-1c   8d
cluster-c1f4-kpw7v-worker-eu-west-1a-9mjh9   Running	   m5.4xlarge   eu-west-1   eu-west-1a   8d
cluster-c1f4-kpw7v-worker-eu-west-1b-q4x9p   Running	   m5.4xlarge   eu-west-1   eu-west-1b   8d
cluster-c1f4-kpw7v-worker-eu-west-1c-vj85z   Running	   m5.4xlarge   eu-west-1   eu-west-1c   8d
ocs-worker-west-1a-nh6jx                     Provisioned   m5.4xlarge   eu-west-1   eu-west-1a   2m43s
ocs-worker-west-1a-wttgg                     Provisioned   m5.4xlarge   eu-west-1   eu-west-1a   2m43s
ocs-worker-west-1b-g4ns7                     Provisioned   m5.4xlarge   eu-west-1   eu-west-1b   2m42s
ocs-worker-west-1b-vsfv6                     Provisioned   m5.4xlarge   eu-west-1   eu-west-1b   2m42s
ocs-worker-west-1c-z7dwp                     Provisioned   m5.4xlarge   eu-west-1   eu-west-1c   2m41s
```

```
NAME                                         PHASE     TYPE         REGION      ZONE         AGE
cluster-c1f4-kpw7v-master-0                  Running   m5.2xlarge   eu-west-1   eu-west-1a   8d
cluster-c1f4-kpw7v-master-1                  Running   m5.2xlarge   eu-west-1   eu-west-1b   8d
cluster-c1f4-kpw7v-master-2                  Running   m5.2xlarge   eu-west-1   eu-west-1c   8d
cluster-c1f4-kpw7v-worker-eu-west-1a-9mjh9   Running   m5.4xlarge   eu-west-1   eu-west-1a   8d
cluster-c1f4-kpw7v-worker-eu-west-1b-q4x9p   Running   m5.4xlarge   eu-west-1   eu-west-1b   8d
cluster-c1f4-kpw7v-worker-eu-west-1c-vj85z   Running   m5.4xlarge   eu-west-1   eu-west-1c   8d
ocs-worker-west-1a-nh6jx                     Running   m5.4xlarge   eu-west-1   eu-west-1a   5m32s
ocs-worker-west-1a-wttgg                     Running   m5.4xlarge   eu-west-1   eu-west-1a   5m32s
ocs-worker-west-1b-g4ns7                     Running   m5.4xlarge   eu-west-1   eu-west-1b   5m31s
ocs-worker-west-1b-vsfv6                     Running   m5.4xlarge   eu-west-1   eu-west-1b   5m31s
ocs-worker-west-1c-z7dwp                     Running   m5.4xlarge   eu-west-1   eu-west-1c   5m30s
```
After 6 minutes the playbook will try to partition the 4TB EBS in 2x2TB partitions, make sure that the playbook will return the following output per node (if it doesn't work you can run again the ansible role and try option #5 PARTITION)
``
  msg:
  - NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  - 'nvme1n1     259:0    0    4T  0 disk '
  - '|-nvme1n1p1 259:6    0    2T  0 part '
  - '`-nvme1n1p2 259:7    0    2T  0 part '
```