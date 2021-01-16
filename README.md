# Sample Project for NodeJS RESTful API + Postgres + Docker + Kubernetes

This is just a simple project that dockerizes a simple API service.

It also contains an example Kubernetes configuration to deploy it with
 app server and a Postgres master.

## Folder Structure

```
/env -- Environment variables
  dev.txt
  prd.txt 
/helm install
  jenkins-values.yml
/Kubernetes -- Kubernetes deployment files
/Minikube - Namespace Yaml file
/Scripts - deployment automation scripts
/src
  db
    migrations -- DB table creaation queries
    seeds  -- simple collections of db queries and utilities for user data
    kenx.js -- Querybuilder config
  server.js -- the main Express app
docker-compose.yml -- multi-container applications
Dockerfile -- text document to create image
jenkinsfile -- pipleine file which is written in groovy for CI/CD
knexfile.js -- defines all database settings for different environments
Make - containing a set of directives used for build automation tool
package.json -- defines scripts for utilities like migrations and seeds
```

## Pre-requisites

- `Minikube - https://kubernetes.io/docs/tasks/tools/install-minikube/` 
- `Docker https://docs.docker.com/engine/installation/`
- `Docker Compose: https://docs.docker.com/compose/install/`
- `SSH keys to setup auto deployment for jenkins`

Verify minikube is running:
```
$ minikube status
minikube: Running
cluster: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.100
```

# How to use it

- Clone this repo: `https://github.com/Shravan6488/node-kubernetes-knex.git`
- `cd node-kubernetes-knex.git`

Create namespaces for below in your minikube:
```
$ kubectl create -f minikube/jenkins-namespace.yaml
$ kubectl create -f minikube/prd-namespace.yaml
$ kubectl create -f minikube/dev-namespace.yaml
```

Create persistent volume (folder /data is persistent on minikube)
```
$ kubectl create -f minikube/jenkins-volume.yaml
```

Execute helm:
```
$ helm install --name jenkins -f helm/jenkins-values.yaml stable/jenkins --namespace jenkins-project
```


Check admin password for jenkins:
```
$ printf $(kubectl get secret --namespace jenkins-project jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
```
 Usage

## Requirements

- GNU Make (available in your package manager of preference)

If you wish to play with it without locally installing Postgres and
Node you can take advantage of `docker` and `docker-compose` which
would help you build the container images and setup a working
environment for you:


## Usage with Docker

Build the images and spin up the containers:

```sh
$ make up
```
This will trigger the pulling and building of the necessary images and
will use `docker-compose` to setup the app and the Postgres
containers.

Run the migrations and seed the database:

```sh
$ make migrate
```
After everything is up and running you can start hitting the API
server via port `3000` like so:

1. [http://localhost:3000](http://localhost:3000)
2. [http://localhost:3000/todos](http://localhost:3000/todos/1)

## Usage with Minikube + Kubernetes
Once `minikube` is running (via `minikube start`), you can trigger a
deployment 
```sh
$ make kube-build
$ make kube-deploy-db-dev
$ make kube-deploy-node-dev
```
This commands will take care of below things
- Secrets
- Volume
- Postgres
- services 
- Node
- migration and Seed the database
Grab the external IP:

```sh
$ kubectl get service node

NAME      TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)          AGE
node      LoadBalancer   10.39.244.136   35.232.249.48   3000:30743/TCP   2m
```

Once everything is up, you can hit the API like so:

1. [http://EXTERNAL_IP:3000](http://EXTERNAL_IP:3000)
2. [http://EXTERNAL_IP:3000/todos](http://EXTERNAL_IP:3000/todos/1) 


## Usage with Jenkins automation

If you want to perform CI/CD automation you can use the EXTERNAL_IP URL of jenkins which was created at the start of this project and perform the below actions:

- Add jenkins URL in your webhook under Repo Settings (this will perform automation when ever code pushed to github)
- Create multi branch pipeline in Jenkins under New item
- Add your Repo URL and proivide the credentials and branch
- jenkinsfile is automatically scan by Pipeline.
- Once everything is configured you can manually trigger the job/perform any code push to your repository

####Note: It will automatically moce to prod deployment and wait for your approval to perform prod deployment


- here is the document for better understanding of multibranch pipeline concept. https://www.jenkins.io/doc/book/pipeline/multibranch/


