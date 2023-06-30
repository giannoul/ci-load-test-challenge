.PHONY: wait-for-endpoint
wait-for-endpoint:
	curl --head -X GET --retry 5 --retry-connrefused --retry-delay 1 http://bar.localhost

.PHONY: install-k6
install-k6:
	curl -L https://github.com/grafana/k6/releases/download/v0.45.0/k6-v0.45.0-linux-amd64.tar.gz --output k6-v0.45.0-linux-amd64.tar.gz
	tar -xvf k6-v0.45.0-linux-amd64.tar.gz
	mv k6-v0.45.0-linux-amd64/k6 /usr/local/bin/

.PHONY: run-k6
run-k6:
	k6 run --summary-trend-stats="p(90),p(95),p(99.9)" k6-load-test/load-test.js --no-color --log-output stdout | grep "checks\|http_req_failed\|http_req_duration" > comment.txt 

.PHONY: install-prometheus
install-prometheus:
	kubectl create ns monitoring; true
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install kube-prometheus prometheus-community/kube-prometheus-stack --namespace  monitoring --create-namespace --set kubeStateMetrics.enabled=false --set nodeExporter.enabled=false --set grafana.enabled=false --version 47.0.0

.PHONY: install-metrics-server
install-metrics-server:
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	helm repo update
	helm upgrade --install --set args={--kubelet-insecure-tls} metrics-server metrics-server/metrics-server --namespace kube-system


.PHONY: prometheus-port-fwd
prometheus-port-fwd:
	kubectl port-forward svc/kube-prometheus-kube-prome-prometheus -n monitoring 9090:9090 &
	sleep 10

.PHONY: get-cpu-usage
get-cpu-usage:
	@curl -s 'http://localhost:9090/api/v1/query?query=sum(rate(container_cpu_usage_seconds_total%7Bid%3D~%22%2Fdocker%2F.%2B%22%2C%20container%3D~%22.%2B-app%22%7D%5B5m%5D))%20without%20(container_name%2C%20endpoint%2C%20id%2C%20name%2C%20namespace%2C%20pod%2C%20service%2C%20image%2C%20instance%2C%20job%2C%20metrics_path%2C%20node%2C%20cpu)%20%0A%0A%0A&g0.tab=1&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1h' | jq

.PHONY: get-memory-usage
get-memory-usage:
	@curl -s 'http://localhost:9090/api/v1/query?query=sum(container_memory_working_set_bytes%7Bid%3D~%22%2Fdocker%2F.%2B%22%2C%20container%3D~%22.%2B-app%22%7D)%20without%20(container_name%2C%20endpoint%2C%20id%2C%20name%2C%20namespace%2C%20pod%2C%20service%2C%20image%2C%20instance%2C%20job%2C%20metrics_path%2C%20node)%20%0A&g0.tab=1&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1h' | jq