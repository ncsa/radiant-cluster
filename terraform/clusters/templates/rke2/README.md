To get the versions for RKE2 you can run the following from the command line:

```bash
curl -s https://api.github.com/repos/rancher/rke2/releases | jq '.[] | select(.prerelease == false) | .name'
```
