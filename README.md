# python-fastapi-websocket-groupchat
python-fastapi-websocket-groupchat

- **To test locally**

```bash
# Create a python virtual environment to avoid installing module globally
python3 -m venv tutorial-env

# activitae the virtual env and install python modules needed to run the application inside the venv
source tutorial-env/bin/activate
python3 -m pip install -r requirements.txt

# Go into app dir and launch the application 
cd app
uvicorn main:app --reload
```
now open localhost:8000 in browser

- **To test locally via docker container**

```bash
docker compose up
```

- **To test locally via minikube**

```bash
minikube start
kubectl apply -f k8s-manifests
```

- **To test locally via aks**

* Deploy aks clsusters using deploy scripts

```bash
az login --use-device-code
bash setup-aks-cred-01.sh
bash setup-aks-cred-02.sh

# below command to get two different aks clusters context
kubectl config get-contexts

# below command to use one of aks clusters context
kubectl config use-context aks-ne-kubenet-investigation-01

kubectl apply -f k8s-manifests
```

- **Migrating load from one cluster to another**

```bash
kubectl config use-context aks-ne-kubenet-investigation-01
# Export all resources from one cluster
kubectl get all --all-namespaces -o yaml > all-resources.yaml

kubectl config use-context aks-ne-kubenet-investigation-02
# Export all resources from another cluster
kubectl apply -f all-resources.yaml
```
