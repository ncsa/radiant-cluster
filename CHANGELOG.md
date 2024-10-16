# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

### Changed
- Remove hard-coded image tag in openstack-cinder-csi so it now follows upstream updates

## 3.2.1 - 2024-09-07

### Changed
- if ncsa_security, disable snap
- if ncsa_security, limit ssh hosts to ncsa only

## 3.2.0 - 2024-08-04

This allows to create a cluster that is RKE2 or K3S as well as RKE1. RKE1 is deprecated and will stop to be supported on July 31st, 2025. If you want to use either RKE2 or K3S you will need to change the `network_plugin`.

In version 3.5.0 the default network for RKE1 will be set to canal, please make sure to either upgrade or explicitly say to use weave.
In version 4.0.0 RKE1 will be removed

### Added
- can use RKE2 or K3S clusters by setting kubernetes_version (leave blank to create RKE1 cluster)
- can specify the key to use for the cluster, and not create a new key for each cluster (`openstack_ssh_key`)

### Changed
- renamed rke1 module to cluster module, until version 4.0.0 rke1 module will be pushed as well as cluster module.
- added commands to clean up default chrony sources

### Removed
- removed rke2 module, this is now part of cluster module

## 3.1.2 - 2024-07-03

### Changed
- use curl https://ncsa.illinois.edu/ to see if network is alive

## 3.1.1 - 2024-06-08

### Changed
- healthmonitor/longhorn are now disabled by default

### Fixed 
- missing secret/storageclass additional helm charts for manila
- ability to enable/disable permissions fix for acme

## 3.1.0 - 2024-06-03

### Added
- can specify the region name when connecting to openstack
- added manilla storage class

## 3.0.0 - 2023-02-22

This removes the old variables for creating machines that were deprecated, and removes references to centos.

### Changed
- removed all deprecated code, clusters are defined in cluster.json

### Added
- ability to set network. Default is weave to be compatible with previous version but this should be changed. Weave is EOL 12/31/2024
  - canal (rancher default)
  - calico
  - flannel
  - weave (deprecated)
  - none
- ubuntu is an alias for ubuntu22 as an os type in cluster. This is in preperation for ubuntu 24.04.

### Removed
- removed centos image reference.

## 2.4.0 - 2023-12-21

### Changed
- changed default priority for redirect to https to be part 9999
- move metallb specific pieces from raw to metallb application
- traefik doesn't use persistant volumes if acme is not enabled
- Use apt-get instead of apt in node provisioning
- Parameterize OpenStack region name

### Fixed
- added pod-security on namespaces to work correctly (needed for talos)
  - metallb
  - cinder
  - longhorn
  - rancher monitoring
- cinder plugins volume for cacert uses /tmp folder (/etc is readonly for talos)

### Added
- cert-manager can now be installed
- nodes are labeled with `ncsa.role` and `ncsa.flavor` from cluster.json
- added option `install_docker` to disable Docker installation when provisioning nodes
- added option `taiga_enabled` to disable Taiga actions in node provisioning
- added option `ncsa_security` to install ncsa specific security options
  - disable IPv6
  - configure chrony for NCSA
  - configure rsyslog for NCSA
  - add qualys account

## 2.3.5 - 2023-09-09

### Fixed
- Change in traefik from redirectTo to be redirectTo.port

## 2.3.4 - 2023-09-09

### Changed
- forgot to update the template

## 2.3.3 - 2023-09-09

### Changed
- added rancher monitoring chart, this can now be managed through argocd.

## 2.3.2 - 2023-08-30

CRITICAL the version 2.2.0 - 2.3.1 could result in all nodes in the cluster being deleted in the case of changes to the userdata.

### Changed
- don't remove nodes when there are changes to userdata, key, availability zone, block_device

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
