.PHONY: run_website stop_website install_kind create_kind_cluster

run_website:
	docker build -t explorecalifornia . && \
	docker run --rm --name explorecalifornia -p 5000:80 -d explorecalifornia

stop_website:
	docker stop explorecalifornia

install_kind:
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64 && \
	./kind --version

create_kind_cluster: install_kind
	kind create cluster --name explorecalifornia && \
	kubectl get nodes