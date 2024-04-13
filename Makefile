.PHONY: run_website stop_website install_kind create_kind_cluster create_docker_registry

run_website:
	docker build -t explorecalifornia . && \
	docker run --rm --name explorecalifornia -p 5000:80 -d explorecalifornia

stop_website:
	docker stop explorecalifornia

install_kind:
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64 && \
	./kind --version

create_kind_cluster: install_kind create_docker_registry
	kind create cluster --name explorecalifornia && \
	kubectl get nodes

create_docker_registry:
	if docker ps | grep -q 'local-registry'; \
	then echo "local-registry already created. Skipping..."; \
	else docker run --name local-registry -d --restart=always -p 5000:5000 registry:2 ; \
	fi