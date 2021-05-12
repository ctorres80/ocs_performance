# Summary
- [Introduction](#Introduction)
- [LAB Requirements](#Requirements)
- [Performance testing](#performance-testing)
- [OpenShift Data Foundation v4.7](#OpenShift-Data-Foundation-v47)
   -  [Order your lab environment from RHPDS](#Order-your-lab-environment-from-RHPDS)
   -  [Deploy 4 OSD nodes in  2 AZs with 3rd AZ and an arbiter node](#Deploy-4-OSD-nodes-in-2-AZs-with-3rd-AZ-with-an-arbiter-node)
   -  [Deploy ODF v4.7 Stretched Cluster](#Deploy-ODF-v47-Stretched-Cluster)
   -  [Scale capacity in ODF v4.7](#Scale-capacity-in-ODF-v47)
   -  [Storage site failure simulation](#Storage-site-failure-simulation)

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
### Deploy 4 OSD nodes in  2 AZs with 3rd AZ with an arbiter node
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
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/5.png)
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

You can open a new shell and verify if the new machinesets and machines are provisioned/running
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
After 6 minutes the playbook will try to partition the 4TB EBS in 2x2TB partitions. Please make sure that the playbook will return the following output per node (if it doesn't work you can run again the ansible role and try option #5 PARTITION)
```bash
for i in {1..2}; do oc get nodes -l topology.kubernetes.io/zone=datacenter$i -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read node; do oc debug node/$node -- lsblk; done; done
```

```
  msg:
  - NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  - 'nvme1n1     259:0    0    4T  0 disk '
  - '|-nvme1n1p1 259:6    0    2T  0 part '
  - '`-nvme1n1p2 259:7    0    2T  0 part '
```
  
  
### Deploy ODF v4.7 Stretched Cluster
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/6.png)
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/7.png)
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/8.png)
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/9.png)
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/10.png)
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/11.png)
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/12.png)
  
  
### Scale capacity in ODF v4.7
Before add capacity please check that you have 4x2TB pvs available

```bash
oc get pv | grep Available
```
```
local-pv-57445269                          2047Gi     RWO            Delete           Available                                                              localblock                             16h
local-pv-5b1e6c5b                          2047Gi     RWO            Delete           Available                                                              localblock                             16h
local-pv-65f7ae73                          2047Gi     RWO            Delete           Available                                                              localblock                             16h
local-pv-e873ba1d                          2047Gi     RWO            Delete           Available                                                              localblock                             16h
```
  
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/13.png)
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/14.png)
  
If you're using the toolbox (not supported) you can connect to the ceph cluster and check the scalability with:
```
watch ceph osd tree
```
```
ID  CLASS WEIGHT   TYPE NAME                       STATUS REWEIGHT PRI-AFF
 -1       10.00000 root default
 -5       10.00000     region eu-west-1
 -4        6.00000         zone datacenter1
 -3        4.00000             host ip-10-0-151-30
  1   ssd  2.00000                 osd.1               up  1.00000 1.00000
  5   ssd  2.00000                 osd.5               up  1.00000 1.00000
-13        2.00000             host ip-10-0-158-55
  3   ssd  2.00000                 osd.3               up  1.00000 1.00000
-10        4.00000         zone datacenter2
-15        2.00000             host ip-10-0-170-28
  2   ssd  2.00000                 osd.2               up  1.00000 1.00000
 -9        2.00000             host ip-10-0-190-23
  0   ssd  2.00000                 osd.0               up  1.00000 1.00000
  4              0 osd.4                             down        0 1.00000
  6              0 osd.6                             down        0 1.00000
  7              0 osd.7                             down        0 1.00000
  

  ID  CLASS WEIGHT   TYPE NAME                       STATUS REWEIGHT PRI-AFF
 -1	  16.00000 root default
 -5	  16.00000     region eu-west-1
 -4        8.00000         zone datacenter1
 -3        4.00000             host ip-10-0-151-30
  1   ssd  2.00000                 osd.1               up  1.00000 1.00000
  5   ssd  2.00000                 osd.5               up  1.00000 1.00000
-13        4.00000             host ip-10-0-158-55
  3   ssd  2.00000                 osd.3               up  1.00000 1.00000
  7   ssd  2.00000                 osd.7               up  1.00000 1.00000
-10        8.00000         zone datacenter2
-15        4.00000             host ip-10-0-170-28
  2   ssd  2.00000                 osd.2               up  1.00000 1.00000
  6   ssd  2.00000                 osd.6               up  1.00000 1.00000
 -9        4.00000             host ip-10-0-190-23
  0   ssd  2.00000                 osd.0               up  1.00000 1.00000
  4   ssd  2.00000                 osd.4               up  1.00000 1.00000  
```
  
At the end you will get 
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/15.png)
  
  
## Storage site failure simulation  
Is recommended to configure storage classs `ocs-storagecluster-ceph-rbd` as default storage class.  
You can deploy whatever stateful application that consume ODF persistent volume claims. In our example we are going to use pgbench with 4 parallel DBs.
