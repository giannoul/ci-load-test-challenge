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
	k6 run --summary-trend-stats="p(90),p(95),p(99.9)" k6-load-test/load-test.js --log-output stdout | grep "checks\|http_req_failed\|http_req_duration" > comment.txt 


