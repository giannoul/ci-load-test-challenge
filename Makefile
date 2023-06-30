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
	@curl -fs --data-urlencode 'query=sum(rate(container_cpu_usage_seconds_total{container=~".+-app"}[5m]))' http://localhost:9090/api/v1/query | jq -r '.data.result[] | [.value[1] ] | @csv'

.PHONY: get-memory-usage
get-memory-usage:
	@curl -fs --data-urlencode 'query=sum(container_memory_working_set_bytes{container=~".+-app"})' http://localhost:9090/api/v1/query | jq -r '.data.result[] | [.value[1] ] | @csv'