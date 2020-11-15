#!/bin/bash
for i in {1..9}
do
	oc delete all,pvc --all -n my-testing-pgbench-ocs-$i
	oc delete project my-testing-pgbench-ocs-$i
done