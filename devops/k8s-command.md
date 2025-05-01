# Kubernetes: Commands Cheat Sheet

## Kubernetes cluster commands
```shell
# Display cluster information
kubectl cluster-info

# List all nodes in the cluster and show IPs
kubectl get nodes -o wide
```

## Kubernetes pod commands
```shell
# List all pods.
kubectl get pods

# Show detailed information about a pod.
kubectl get pods -o wide

# Show pods who have a specific label.
kubectl get pods -1 <label>=<value>

# Show one specific pod.
kubectl get pod <name>

# Show a pod's details.
kubectl describe pod

# View logs of a pod.
kubectl logs <pod>

# Execute a command inside a pod.
kubectl exec -it <pod>

# Delete a pod.
kubectl delete pod <pod>

# Displays an overview of the Pod resource.
kubectl explain pod <resource>
```

## Kubernetes deployment commands
```shell
# Create a deployment.
kubectl create deployment <name> --image=<image>

# List all deployments.
kubectl get deployments

# Show deployment details of one deployment. 
kubectl describe deployment <name>

# Increase or decrease a deployment. 
kubectl scale deployment <name> --replicas=<number> 

# Restart a deployment.
kubectl rollout restart deployment/<name> 

# View the status of a deployment.
kubectl rollout status deployment/<name>

# Create a deployment and print the YAML.
kubectl create deployment <name> --image=<image> -o yaml

# Create a deployment without applying it # and print the YAML file.
kubectl create deployment <name> --image=<image> -o yaml --dry-run=client

# Create a deployment without applying it # and store the YAML file inside "name.yaml"
kubectl create deployment <name> --image=<image> -o yaml --dry-run-client> name.yaml
```

## Kubernetes service commands
```shell
# List all services.
kubectl get services

# Show service details.
kubectl describe service <name>

# Expose a pod to a service.
kubectl expose pod <name>

# Delete a service.
kubectl delete service <name>

# Forward a local port to a pod.
kubectl port-forward <pod> <local-port>:<remote-port>
```

## Kubernetes configmap & secret commands
```shell
# Create a ConfigMap.
kubectl create configmap <name> --from-literal=<key>=<value>

# Create a Secret.
kubectl create secret generic <name> --from-literal=<key>=<value>

# List all ConfigMaps.
kubectl get configmaps

# List all Secrets.
kubectl get secrets

# Show ConfigMap details.
kubectl describe configmap <name>
```

## Kubernetes namespace commands
```shell
# List all namespaces.
kubectl get namespaces

# Create a namespace.
kubectl create namespace <name>

# Delete namespace.
kubectl delete namespace <name>

# Switch to a different namespace.
kubectl config set-context --current-namespace=<name>
```

## Kubernetes resource commands
```shell
# Apply a resource config file.
kubectl apply -f <file>

# Edit a resource file inside your terminal.
kubectl edit <type> <name>

# Delete a resource from a config file.
kubectl delete -f <file>

# List resources of a specific type.
kubectl get <type>

# Show details about a specific resource.
kubectl describe <type> <name>
```

## Kubernetes statistics & event commands
```shell
# Display node resource usage.
kubectl top nodes

# Display pod resource usage. 
kubectl top pods

# Show recent cluster events. 
kubectl events

# List all cluster events.
kubectl get events
```

## Kubernetes permissions 
```shell
# List all roles.
kubectl get roles
```
