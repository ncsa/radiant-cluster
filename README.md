This is mirrored to GitHub, the code and terraform modules can be found at: https://git.ncsa.illinois.edu/kubernetes/radiant-cluster

# Create Kubernetes On Radiant

These are the modules used by the terraform scripts in radiant-cluster-template. This wil create the nodes on radiant (openstack), and create a kubernetes cluster leveraging rancher.

This also has the code to hook into argocd for deployment of most common aspects of a kubernetes cluster

# TerraForm Modules

Currently the only supported (and used) modules are RKE1 and ArgoCD.

## ArgoCD (terraform/modules/argocd)

Creates a project/cluster/app in the managed argocd setup. The users with access to the cluster will also have access to this project in argocd. The app installed will point to the charts/apps folder which installs most of the components of the kubernetes cluster. Many of thse can be turn and off using the variables.

The following modules are enabled by default:
- ingress controller (traefik by default)
- nfs provisioner (connected to taiga)
- cinder provisioner (volumes as storage in openstack)
- metallb (loadbalancer using floating ips from cluster module)
- sealed secrets
- monitoring
- raw kubernetes
The following modules are enabled by default:
- longhorn 
- healthmonitor (expects a secret, so sealed secrets should be enabled)

## Cluster (terraform/modules/cluster)

Creates a cluster using rancher and openstack. This will create the following pieces for the
cluster:
- private network
- floating IP for load balancer
- security group
  - port 22 open to NCSA
  - port 80/443 open to the world
  - port 6443 open to all 3 rancher machines
  - all ports open to hosts in same network
- ssh key (see note below)
- rancher managed cluster 
  - admin/normal users using ldap
- control nodes, with a floating IP for external access
  - iscsi (longhorn) and nfs installed
  - docker installed in case of RKE1 cluster
  - connected to rancher
- worker nodes, private network
  - iscsi (longhorn) and nfs installed
  - docker installed in case of RKE1 cluster
  - connected to rancher

### SSH key

If multiple people run `terraform` it is critical that **everybody** has the same public key in openstack! This can be done by sharing the public key and asking people to import the public key in openstack and naming it the same as the cluster. If this is not done each user will creat their own public/private keypair and you end up with a mix of keys that are injected in the cluster.

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

# ArgoCD (argocd)

This is the scripts used to bootstrap argocd in one cluster. This installation is used in the argocd terraform module to create projects/cluster.

# Charts (charts)

This contains helm charts leveraged by ArgoCD to install the modules mentioned earlier as well as a helmchart to install the healthmonitor.

## apps (charts/apps)

This is an app that creates new apps to install all the components configured by the argocd terraform module

## healthmonitor (charts/healthmonitor)

This module can check different aspects, but mainly is used to make sure the network is working as expected and the connections to NFS are working correctly.


# Traefik Version Configuration

The Traefik ingress controller version can be configured at multiple levels with the following precedence (highest to lowest):

1. **Terraform variable** (`traefik_version`): When set to a non-empty string, this value is passed through to the helm chart
2. **Helm chart default**: When terraform does not pass a version, `charts/apps/templates/ingresscontroller/traefik.yaml` defaults to `"*"` (latest)

## Configuration Examples

### Pin to a specific version via Terraform
```hcl
# In your terraform.tfvars
traefik_version = "39.*"
```

### Use latest version (default behavior)
Do not set `traefik_version` in terraform, or set it to an empty string:
```hcl
traefik_version = ""
```

This allows the helm chart default (`"*"`) to take effect, always pulling the latest Traefik chart version.

## How it works

- `terraform/modules/argocd/variables.tf`: Defines `traefik_version` with default `""`
- `terraform/modules/argocd/templates/argocd.yaml.tmpl`: Only renders `version:` when `traefik_version != ""`
- `charts/apps/templates/ingresscontroller/traefik.yaml`: Uses `default "*"` as fallback

