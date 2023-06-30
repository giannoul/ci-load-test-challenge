# ci-load-test-challenge
CI Load Test take-home challenge

## Tools used

### Terraform 
In order to spin up the Kind cluster and create the Kubernetes resources, we utilize Terraform and specifically:
* [kind_cluster](https://registry.terraform.io/providers/tehcyx/kind/latest/docs/resources/cluster): this provider allows us to spin up the Kind cluster
* [kustomization](https://registry.terraform.io/providers/kbst/kustomization/latest/docs): this provider allows us to define the manifests to be applied to the Kubernetes cluster

The Kustomization provider tkaes care of applying the following:
* the nginx ingress controller
* deployments, services and ingress for the foo and bar applications


### Makefile
In order to avoid legthy commands in GitHub Actions, we use a `Makefile` where some auxiliary commands are defined. These commands aim to be used by the GitHub Action workflow steps.

### K6
For the load testing part we utilize [k6](https://k6.io/docs/). It is a simple, yet powerful, load testing tool that exports the required metrics/results.


