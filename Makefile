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

create_kind_cluster: install_kind create_docker_registry
	./kind create cluster --name explorecalifornia --config ./kind_config.yaml || true && \
	kubectl get nodes

create_docker_registry:
	if docker ps | grep -q 'local-registry'; \
	then echo "local-registry already created. Skipping..."; \
	else docker run --name local-registry -d --restart=always -p 5000:5000 registry:2 ; \
	fi

connect_registry_to_kind_network:
	docker network connect kind local-registry || true

connect_registry_to_kind: create_docker_registry connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yaml

create_kind_cluster_with_registry:
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind

delete_kind_cluster: delete_docker_registry
	./kind delete cluster --name exporecalifornia

delete_docker_registry:
	docker stop local-registry && docker rm local-registry || true

check_kubesystem_namespace_running_pods:
	kubectl get pods --namespace kube-system
