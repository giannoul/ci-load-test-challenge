terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.1.1"
    }
    kustomization = {
      source = "kbst/kustomization"
      version = "0.9.4"
    }
  }
}

provider "kind" {
  # Configuration options
}

provider "kustomization" {
  # Configuration options
  kubeconfig_path = "~/.kube/config"
}