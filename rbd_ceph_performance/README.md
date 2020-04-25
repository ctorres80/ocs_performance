rbd_ceph_performance
=========

This ansible role will automate following workflow:
- Use [clients] from ceph-ansible inventory that have admin keys on your ceph cluster
- Create a dedicated rbd images in the format rbd_name_{{ ansible_hostname }}
- Run rbd bench in parallel from each client present in the [clients] ceph-ansible inventory group
- The rbd bench output is provided at the end you can redirect to an output file for further analysis
- Multiple workload profiles are managed by this role: :
  - profile: sequential, random
  - type: write, read, rw 
  - block size: 4K, 8K, 16K, 32K, 64K, 128K, 256K, 512K, 1024K
  - file size: G


Requirements
------------

- ansible 2.8.10

packages:
- ceph-common

Role Variables
--------------

Following the default values, please adapt them based on your requirements
- pool_name: 'rbd' 		        -> the name of the ceph pool
- rbd_name: 'volume_testing' 	-> the rbd image name
- rbd_size: '5G' 			        -> the rbd image size
- io_type: 'rw'		            -> if read or write or rw IO should be run
- io_size: '64K' 			        -> how big every IO should be (in B/K/M/G/T).
- io_threads: '1'			        -> how many IOs are done in parallel
- io_total: '2G'			        -> how much total IO should be done
- io_pattern: 'rand'	    	  -> sequential or random IO pattern, supported: rand, seq
- rw_mix_read: 50			        -> required for mixed workload rw
- rbd_image_name: '{{ rbd_name }}_{{ ansible_hostname }}'	-> the rbd_image_name include the hostname
-  path_fio_files: '/root/ceph_performance'		-> next version will include fio 	

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - name: use motd role playbook
      hosts: clients
      become: true
      roles:
        - rbd_ceph_performance

License
-------

BSD

Author Information
------------------

My name is Carlos Torres, I'm a storage guy and really love Ceph,  I hope this ansible role can help you for ceph performance benchmarking.
