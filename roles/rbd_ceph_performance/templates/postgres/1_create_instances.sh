#!/bin/bash
for i in {1..9}
do
	oc create namespace my-testing-pgbench-ocs-$i
	oc label namespace my-testing-pgbench-ocs-$i "openshift.io/cluster-monitoring=true"
done
for i in {1..9}
do
        oc new-app --name=postgresql-ocs-$i --template=postgresql-persistent-ocs -n my-testing-pgbench-ocs-$i
done