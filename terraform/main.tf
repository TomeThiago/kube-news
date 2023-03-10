terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "ssh_key" {
  name       = var.ssh_key_name
  public_key = file(var.ssh_key_file)
}

resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins-vm"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [digitalocean_ssh_key.ssh_key.fingerprint]
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = "k8s"
  region  = var.region
  version = "1.25.4-do.0"

  node_pool {
    name       = "default-nyc1"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "ssh_key_name" {
  default = "terraform"
}

variable "ssh_key_file" {
  default = "~/.ssh/terraform.pub"
}

variable "do_token" {
  default = ""
}

variable "region" {
  default = "nyc1"
}

output "jenking_ip" {
  value = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "kubectl" {
  content  = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
  filename = "kube_config.yaml"
}