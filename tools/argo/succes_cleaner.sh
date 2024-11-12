#!/bin/bash

# Configurar variables
NAMESPACE=""  # Ajusta esto al namespace donde está instalado Argo Workflow
DAYS_OLD=  # Ajusta esto para cambiar el número de días

# Obtener la fecha actual menos el número de días especificado
CUTOFF_DATE=$(date -d "$DAYS_OLD days ago" -u +"%Y-%m-%dT%H:%M:%SZ")

# Obtener workflows más antiguos que el número de días especificado
OLD_WORKFLOWS=$(kubectl get workflows -n $NAMESPACE -o json | jq -r --arg CUTOFF "$CUTOFF_DATE" '.items[] | select(.status.finishedAt < $CUTOFF and (.metadata.labels["workflows.argoproj.io/workflow-template"] // "none" != "none")) | .metadata.name')

# Contador para workflows procesados
PROCESSED_COUNT=0

# Iterar sobre los workflows antiguos y eliminarlos junto con sus pods
for workflow in $OLD_WORKFLOWS
do
    echo "Procesando workflow antiguo: $workflow"
    
    # Obtener el nombre del template asociado a este workflow
    TEMPLATE_NAME=$(kubectl get workflow $workflow -n $NAMESPACE -o jsonpath='{.metadata.labels.workflows\.argoproj\.io/workflow-template}')
    
    # Verificar si el workflow no es el más reciente de su template
    IS_LATEST=$(kubectl get workflows -n $NAMESPACE -l workflows.argoproj.io/workflow-template=$TEMPLATE_NAME --sort-by=.status.startedAt -o json | jq -r --arg WF "$workflow" '.items[-1].metadata.name != $WF')
    
    if [ "$IS_LATEST" = "true" ]; then
        # Eliminar los pods asociados al workflow
        kubectl delete pods -n $NAMESPACE --selector=workflows.argoproj.io/workflow=$workflow

        # Eliminar el workflow
        kubectl delete workflow -n $NAMESPACE $workflow

        echo "  Workflow antiguo y pods asociados eliminados: $workflow"
        PROCESSED_COUNT=$((PROCESSED_COUNT + 1))
    else
        echo "  Saltando workflow $workflow porque es la ejecución más reciente de su template ($TEMPLATE_NAME)"
    fi
done

echo "Limpieza completada. Total de workflows antiguos eliminados: $PROCESSED_COUNT"
