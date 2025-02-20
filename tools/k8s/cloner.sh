#!/bin/bash

SOURCE_NAMESPACE="source-namespace"
TARGET_NAMESPACE="target-namespace"

kubectl get namespace $TARGET_NAMESPACE >/dev/null 2>&1 || kubectl create namespace $TARGET_NAMESPACE

echo "📦 Copiando ConfigMaps..."
kubectl get configmaps -n $SOURCE_NAMESPACE -o name | while read cm; do
    kubectl get $cm -n $SOURCE_NAMESPACE -o yaml | \
    sed "s/namespace: $SOURCE_NAMESPACE/namespace: $TARGET_NAMESPACE/g" | \
    kubectl apply -n $TARGET_NAMESPACE -f -
done

echo "🔐 Copiando Secrets..."
kubectl get secrets -n $SOURCE_NAMESPACE -o name | while read secret; do
    kubectl get $secret -n $SOURCE_NAMESPACE -o yaml | \
    sed "s/namespace: $SOURCE_NAMESPACE/namespace: $TARGET_NAMESPACE/g" | \
    kubectl apply -n $TARGET_NAMESPACE -f -
done

echo "📄 Copiando Recursos del Namespace (Deployments, Services, Ingress, PVCs, HPA, etc)..."
kubectl get all -n $SOURCE_NAMESPACE -o yaml > /tmp/resources-${SOURCE_NAMESPACE}.yaml

yq eval 'del(.items[].metadata.uid, .items[].metadata.resourceVersion, .items[].metadata.creationTimestamp, .items[].metadata.annotations."kubectl.kubernetes.io/last-applied-configuration")' -i /tmp/resources-${SOURCE_NAMESPACE}.yaml

yq eval '(.items[].metadata.namespace) = strenv(TARGET_NAMESPACE)' -i /tmp/resources-${SOURCE_NAMESPACE}.yaml

kubectl apply -f /tmp/resources-${SOURCE_NAMESPACE}.yaml

echo "✅ Namespace '$SOURCE_NAMESPACE' clonado a '$TARGET_NAMESPACE' correctamente."
