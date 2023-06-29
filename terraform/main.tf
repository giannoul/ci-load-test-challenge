resource "kind_cluster" "current" {
    name           = "ci-cluster"
    wait_for_ready = true
    node_image = "kindest/node:v1.25.11"

  kind_config {
      kind        = "Cluster"
      api_version = "kind.x-k8s.io/v1alpha4"

      node {
          role = "control-plane"

          kubeadm_config_patches = [
              "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
          ]

          extra_port_mappings {
              container_port = 80
              host_port      = 80
          }
      }

      node {
          role = "worker"
      }
  }
}


# https://github.com/kubernetes-sigs/kustomize/blob/master/examples/remoteBuild.md#remote-targets
data "kustomization_build" "manifests" {
  path = "./manifests"
}

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "p0" {
  for_each = data.kustomization_build.manifests.ids_prio[0]
  manifest = data.kustomization_build.manifests.manifests[each.value]
  depends_on = [kind_cluster.current]
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
# wait 2 minutes for any deployment or daemonset to become ready
resource "kustomization_resource" "p1" {
  for_each = data.kustomization_build.manifests.ids_prio[1]
  manifest = data.kustomization_build.manifests.manifests[each.value]
  wait = true
  timeouts {
    create = "8m"
  }
  depends_on = [kustomization_resource.p0]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "p2" {
  for_each = data.kustomization_build.manifests.ids_prio[2]
  manifest = data.kustomization_build.manifests.manifests[each.value]
  depends_on = [kustomization_resource.p1]
}