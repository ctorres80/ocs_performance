# Synthetic benchmark tool for Block, File and S3 in OpenShift Data Foundation
- [Introduction](#Introduction)
- [Requirements](#Requirements)
- [Performance testing](#performance-testing)
    - [Clone the repo](#clone-the-repo)
    - [Fio testing](#fio-testing)
    - [Running the fio benchmark pods](#running-the-fio-benchmark-pods)
    - [Monitoring performance during benchmark](#monitoring-performance-during-benchmark)
         - [Using Openshift Webconsole and grafana](#using-openshift-webconsole-and-grafana)
         - [Using toolbox for cephrbd monitoring](#using-toolbox-for-cephrbd-monitoring)
- [Cleaning environment](#cleaning-environment)
    - [Delete all](#delete-all)

## Introduction 
This is in an interactive ansible role for performance testing with synthetic benchmarking workloads, the purpose is to simulate different workload profiles based on your inputs for BLock, File and S3 OBC in OpenShift Data Foundation.  
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
### Just watch the video ;)
[![Watch the video](https://github.com/ctorres80/ocs_performance/blob/master/roles/rbd_ceph_performance/files/video_picture.png)](https://youtu.be/KssJ35seKWU)