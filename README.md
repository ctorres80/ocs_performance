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
- Replace the token authentication secret to allow access to `ocs-registry:latest-4.7`
- Waiting for 5 mins, you can monitor what's happening with:  
```bash
watch oc get nodes
```
- Install the ODF v4.7 Operator from template `roles/rbd_ceph_performance/templates/odfv47.yml`
- If everything has been completed successfully you will see that the OCS Operator version 4.7 will be available 
![OCS v4.7](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/3.png)

`# 7 -> DEPLOY STRETCHED CLUSTER VMs: 3 AZs, Replica-4 (2 OSD nodes in 2 AZ + arbiter)     #`
Please check that you're in this condition before start  
```bash
oc get machineset -n openshift-machine-api
```
```
NAME                                   DESIRED   CURRENT   READY   AVAILABLE   AGE
cluster-c1f4-kpw7v-worker-eu-west-1a   1         1         1       1           8d
cluster-c1f4-kpw7v-worker-eu-west-1b   1         1         1       1           8d
cluster-c1f4-kpw7v-worker-eu-west-1c   1         1         1       1           8d
```