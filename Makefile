.PHONY: run_website stop_website

run_website:
	docker build -t explorecalifornia . && \
	docker run --rm --name explorecalifornia -p 5000:80 -d explorecalifornia

stop_website:
	docker stop explorecalifornia