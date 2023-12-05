resource null_resource auditlog_activation {
provisioner local-exec {
command = <<BASH
ibmcloud plugin install ./bin/container-service-linux-amd64-1.0.579 -f
service="auditlog--ibmcloud-kube-audit"
ibmcloud ks cluster ca get -c --output json | jq -r .caCert | base64 -d > caCert.crt
read -r client_cert client_key <<< $(kubectl config view --minify | grep 'client-certificate|client-key' | awk -F':' '{print $2}' | tr -s '\n' ' ')
ibmcloud ks cluster master audit-webhook set --cluster \
--remote-server https://127.0.0.1:2040/api/v1/namespaces/${var.audit_namespaces}/services/auditlog--ibmcloud-kube-audit/proxy/post \
--ca-cert caCert.crt --client-cert $client_cert --client-key $client_key

ibmcloud oc cluster master refresh --cluster

BASH
interpreter = ["/bin/bash", "-c"]
environment = {
KUBECONFIG = var.kube_config_path
}
}
}

var "kube_config_path" {
}

var "audit_namespaces" {
}
