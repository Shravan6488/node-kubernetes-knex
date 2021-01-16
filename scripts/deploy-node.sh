set -euo pipefail
set -a
env_folder=env

source $env_folder/$1.txt
cat $env_folder/$1.txt


echo "Substitute ENV Variable"

envsubst < kubernetes/node-deployment.yaml | kubectl  apply -f - 
envsubst < kubernetes/node-service.yaml | kubectl  apply -f - 

kubectl get pods -n $NAMESPACE

# Query to DB using knex query builder
POD=$(kubectl get pods -n $NAMESPACE --selector=app==node -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | tail -n 1)

echo "Pod name $POD"
if [ -z "$POD" ]; then
    echo "No pod available to run migrations."
    exit 1;
else
    kubectl exec -ti $POD -n $NAMESPACE --stdin --tty knex migrate:latest
    kubectl exec -ti $POD -n $NAMESPACE knex seed:run
fi

