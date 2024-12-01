#!/usr/bin/env bash

create_admin_user() {
    kubectl -n default apply -f ./../k8s/admin-user.yml
}

is_repository_added() {
    if [ "$(helm repo list -o json | jq '.[].url' -r)" = "https://kubernetes.github.io/dashboard" ]; then
        echo 0
    else
        echo 1
    fi
}

is_dashboard_running() {
    if [ "$(helm list -o json | jq '.[].chart' -r)" = "kubernetes-dashboard-7.10.0" ]; then
        echo 0
    else
        echo 1
    fi
}

install_dashboard_package() {
    if [ $(is_repository_added) = 1 ]; then
        helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard
    fi
    if [ $(is_dashboard_running) = 1 ]; then
        helm install dashboard kubernetes-dashboard/kubernetes-dashboard
    fi
}

expose_dashboard() {
  echo "==> Dashboard available at https://127.0.0.1:8443"
  kubectl -n default port-forward \
    $(kubectl get pods -n default \
      -l "app.kubernetes.io/instance=dashboard" \
      -o jsonpath="{.items[0].metadata.name}") \
    $(kubectl get pods -n default \
      -l "app.kubernetes.io/instance=dashboard" \
      -o jsonpath="{.items[0].spec.containers[0].ports[0].containerPort}"):8443
}

create_admin_token() {
    kubectl -n default create token admin-user | xclip -selection clipboard && \
        echo "==> Token copied to clipboard"
}

install_dashboard_package && \
    create_admin_token && \
    expose_dashboard
