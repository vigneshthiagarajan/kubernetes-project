.PHONY: run_website stop_website install_kind create_kind_cluster create_docker_registry connect_registry_to_kind_network connect_registry_to_kind create_kind_cluster_with_registry \ 
		delete_kind_cluster delete_docker_registry

run_website:
	docker build -t explorecalifornia . && \
	docker run --rm --name explorecalifornia -p 5000:80 -d explorecalifornia

stop_website:
	docker stop explorecalifornia

install_kind:
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64 && \
	./kind --version

Deleted clusters: ["explore-california"]
create_docker_registry:
	if docker ps | grep -q 'local-registry'; \
	then echo "local-registry already created. Skipping..."; \
	else docker run --name local-registry -d --restart=always -p 5000:5000 registry:2 ; \
	fi

connect_registry_to_kind_network:
	docker network connect kind local-registry || true

connect_registry_to_kind: create_docker_registry connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yaml

create_kind_cluster: install_kind create_docker_registry
	./kind create cluster --image=kindest/node:v1.21.12 --name explorecalifornia --config ./kind_config.yaml || true
	kubectl get nodes
# delete kind clusters - 
# ./kind delete clusters explorecalifornia

create_kind_cluster_with_registry:
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind

delete_kind_cluster: delete_docker_registry
	./kind delete cluster --name exporecalifornia

delete_docker_registry:
	docker stop local-registry && docker rm local-registry || true

check_kubesystem_namespace_running_pods:
	kubectl get pods --namespace kube-system

# Tag and push explorecalifornia docker image to local registry
#  docker tag explorecalifornia localhost:5000/explorecalifornia
#  docker push localhost:5000/explorecalifornia

# Create docker registry and kind cluster - connect them to same network
#  $ make create_kind_cluster_with_registry

# $ kubectl apply -f deployment.yaml
# deployment.apps/explorecalifornia created

# Check running pods
# $ kubectl get pods -l app=explorecalifornia
# NAME                                 READY   STATUS         RESTARTS   AGE
# explorecalifornia-6cc9fb968c-zqsbv   0/1     ErrImagePull   0          30s

# Mount port from k8s to my machine

# Port forwarding in k8s