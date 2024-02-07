This is mirrored to GitHub, the code and terraform modules can be found at: https://git.ncsa.illinois.edu/kubernetes/radiant-cluster

# Create Kubernetes On Radiant

These are the modules used by the terraform scripts in radiant-cluster-template. This wil create the nodes on radiant (openstack), and create a kubernetes cluster leveraging rancher.

This also has the code to hook into argocd for deployment of most common aspects of a kubernetes cluster

# TerraForm Modules

Currently the only supported (and used) modules are RKE1 and ArgoCD.

## ArgoCD (terraform/modules/argocd)

Creates a project/cluster/app in the managed argocd setup. The users with access to the cluster will also have access to this project in argocd. The app installed will point to the charts/apps folder which installs most of the components of the kubernetes cluster. Many of thse can be turn and off using the variables.

If all options are enabled this will install:
- ingress controller (traefik v2)
- nfs provisioner (connected to taiga)
- cinder provisioner (volumes as storage in openstack)
- metallb (loadbalancer using floating ips from RKE1 module)
- sealed secrets
- healthmonitor (expects a secret, so sealed secrets should be enabled)
- raw kubernetes (used by metallb)

## RKE1 (terraform/modules/rke1)

Creates a cluster using rancher and openstack. This will create the following pieces for the
cluster:
- private network
- floating IP for load balancer
- security group
  - port 22 open to the world
  - port 80/443 open to the world
  - ports 30000 - 32000 open to the world
  - port 6443 open to NCSA
  - all ports open to hosts in same network
- ssh key
- rancher managed RKE1 cluster 
  - monitoring if requested
  - longhorn if requested
  - admin/normal users using ldap
- control nodes, with a floating IP for external access
  - iscsi (longhorn) and nfs installed
  - docker installed
  - connected to rancher
- worker nodes, private network
  - iscsi (longhorn) and nfs installed
  - docker installed
  - connected to rancher

### Definition of machines

Create a file named `cluster.json` following the example in `cluster.example.json` and customize to define the desired set of nodes. The global cluster name is combined with the `name` value and the index of the machine to generate the individual hostnames, where the index ranges from `start_index` to `start_index + count - 1`. The `start_index` spec allows you to avoid name collisions while having multiple machine configurations following the same sequential naming convention. 

For example, if the cluster name is `k8s`, then the `cluster.example.json` file would generate the following list of machines:

```plain
k8s-controlplane-1 (gp.medium, 40GB disk)
k8s-controlplane-2 (gp.medium, 40GB disk)
k8s-controlplane-3 (gp.medium, 40GB disk)
k8s-worker-01      (gp.xlarge, 60GB disk)
k8s-worker-02      (gp.xlarge, 60GB disk)
k8s-worker-03      (m1.xlarge, 60GB disk)
```



## RKE2 (terraform/modules/rke2)

This module is not supported yet, will create an RKE2 cluster

## compute/openstack and rancher

No longer supported

# ArgoCD (argocd)

This is the scripts used to bootstrap argocd in one cluster. This installation is used in the argocd terraform module to create projects/cluster.

# Charts (charts)

This contains helm charts leveraged by ArgoCD to install the modules mentioned earlier as well as a helmchart to install the healthmonitor.

## apps (charts/apps)

This is an app that creates new apps to install all the components configured by the argocd terraform module

## healthmonitor (charts/healthmonitor)

This module can check different aspects, but mainly is used to make sure the network is working as expected and the connections to NFS are working correctly.

