#!/bin/bash
# discover the AZ that host the nodes to cordon and delete pods
az=$(oc get nodes -l topology.kubernetes.io/zone=datacenter2 -o jsonpath='{range .items[*]}{.metadata.labels.topology\.ebs\.csi\.aws\.com\/zone}{"\n"}{end}' | sort -u)
# cordon the discovered nodes (included ODF nodes)
oc get nodes -l topology.ebs.csi.aws.com/zone=$az -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read node; do oc adm cordon $node; done
# delete application pods in project my-shared-storage
oc get nodes -l topology.ebs.csi.aws.com/zone=$az -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read node; do oc -n my-shared-storage get pods --field-selector spec.nodeName=$node -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}';done | xargs -n 1 -I {} oc -n my-shared-storage delete po {}
# delete ODF MON pods
oc -n openshift-storage get pods -l topology-location-zone=datacenter2 -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | xargs -n 1 -I {} oc -n openshift-storage delete po {}
# delete ODF OSD pods
oc -n openshift-storage get pods -l stretch-zone=datacenter2 -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | xargs -n 1 -I {} oc -n openshift-storage delete po {}
sleep 60
oc get nodes -l topology.ebs.csi.aws.com/zone=$az -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read node; do oc adm uncordon $node; done