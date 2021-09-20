#!/bin/bash

#ARGOCD_URL=argocd.141.142.223.4.nip.io
ARGOCD_URL=argocd.kooper.net

# ----------------------------------------------------------------------
# install argocd-server
sed "s/@ARGOCD_URL@/${ARGOCD_URL}/g" values-argocd-server.yaml > sed-argocd-server.yaml
helm upgrade --namespace argocd --install --create-namespace argocd argo/argo-cd --values sed-argocd-server.yaml

# create project to hold arogcd apps
kubectl apply -n argocd -f argocd-project.yaml

# create app to update argocd-server
cat templ-argocd-server.yaml > app-argocd-server.yaml
sed 's/^/        /' sed-argocd-server.yaml >> app-argocd-server.yaml
rm sed-argocd-server.yaml
kubectl apply -f app-argocd-server.yaml
rm app-argocd-server.yaml

# ----------------------------------------------------------------------
# install argocd-notifications
sed "s/@ARGOCD_URL@/${ARGOCD_URL}/g" values-argocd-notifications.yaml > sed-argocd-notifications.yaml
curl -s https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/v1.1.1/catalog/install.yaml | egrep '^  (trigger.|template.|  )'  >> sed-argocd-notifications.yaml
helm upgrade --namespace argocd --install --create-namespace argocd-notifications argo/argocd-notifications  --values sed-argocd-notifications.yaml

# create appp to update argocd-notifications
cat templ-argocd-notifications.yaml > app-argocd-notifications.yaml
sed 's/^/        /' sed-argocd-notifications.yaml >> app-argocd-notifications.yaml
rm sed-argocd-notifications.yaml
kubectl apply -f app-argocd-notifications.yaml
rm app-argocd-notifications.yaml

# ----------------------------------------------------------------------
# install ingress route for traefik v2
sed "s/@ARGOCD_URL@/${ARGOCD_URL}/g" templ-argocd-ingress.yaml > argocd-ingress.yaml
kubectl apply -f argocd-ingress.yaml || echo "Could not install ingress routes, no traefik v2 installed"

# ----------------------------------------------------------------------
# install secrets for git repo
kubectl apply -f secrets-argocd.yaml
