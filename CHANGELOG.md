# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## 2.3.1 - 2023-08-26

### Changed
- fix broken cinder, missing v1.28.0 imaes
- point argocd to git.ncsa.illinois.edu instead of github

## 2.3.0 - 2023-08-25

### Changed
- allow to specify what machines you can ssh from to controlplanes

## 2.2.0 - 2023-08-07

### Removed
- removed nodeports in securitygroup

## 2.1.1 - 2023-08-03

### Changed
- use /32 instead of /16 for rancher ips

## 2.1.0 - 2023-08-03

In the next major update all backwards compatible code will be removed. Please migrate to teh cluster_machine setup and set controlplane_count and worker_count to 0

### Changed

- This add backwards compatibility to the stack, you still need ot define the cluster machines

## 2.0.0 - 2023-06-28

This is a breaking change. You will need to update your terraform code to use this new version. This is an example of the variable `cluster_machine`.

```json
[
  {
    "name": "controlplane",
    "role": "controlplane",
    "count": 3,
    "flavor": "gp.medium",
    "os": "centos"
  },
  {
    "name": "worker",
    "count": 3,
    "flavor": "gp.large",
    "disk": 40,
    "os": "centos"
  }
]
```

### Added

- Can use ubuntu for OS
- Can have differt types of machines (e.g. gpu and no cpu)

### Changed

- Removed all variables to specify machines used in cluster

## 1.3.1 - 2023-01-31

### Added
- Ability to set iprange that can access the kubapi (port 6443)

### Changed
- disabled argocd deployment of monitoring since it never synchronizes in argocd
- ignore changes to os/flavor of the nodes

## 1.3.0 - 2022-11-21

### Changed
- monitoring is now managed in argocd, this will make it such that the latest version will be installed/upgraded

### Removed
- removed the argocd-master flag, now all clusters are assumed to be external, including where argocd runs

## 1.2.2 - 2022-10-24

### Changed
- compute nodes in rke1 now set availability zone (default nova), availabilty zone is ignored for existing nodes.

## 1.2.1 - 2022-10-13

### Changed
- traefik has many major versions released, right now it is set to *

## 1.2.0 - 2022-09-29

### Changed
- update openstack-cinder-csi from 1.* to 2.*

## 1.1.0 - 2022-09-24

### Changed
- allow multiple nfs servers to be specified in charts/apps

## 1.0.1 - 2022-09-19

### Changed
- if an app is disabled, don't populate values

## 1.0.0 - 2022-09-16

This is the first version. This has evolved and now works on the current
setup of radiant. This is split in 3 pieces

- argocd : template to install argocd on server, this is probably not needed and is only used to install a central argocd.
- charts : this contains two charts
  - healthmonitor : a simple monitor to see if services are up
  - apps : the infrastructure components for a cluster
    - ingresscontroller : traefik (v1, v2) 
    - storageclasses : cinder, longhorn and nfs
    - sealedsecrets
    - metallb (load balancer)
    - raw (raw kubernetes, also used by metallb)
- terraform : creates the cluster in openstack (radiant)
  - rke1 : leverages rancher, argocd and openstack to create a fully working kubernetes cluster.
