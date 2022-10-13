# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).


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
