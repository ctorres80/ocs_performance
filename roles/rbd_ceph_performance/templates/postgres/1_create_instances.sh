#!/bin/bash
for i in {1..9}
do
	oc create namespace my-postgres-$i
	oc label namespace my-postgres-$i "openshift.io/cluster-monitoring=true"
done
#oc new-app --name=postgresql-block-4 --template=postgresql-persistent-ocs
for i in {1..9}
do
        oc new-app --name=postgresql-block-$i --template=postgresql-persistent-ocs -n my-postgres-$i
done