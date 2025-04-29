terraform {
  required_version = ">= 1.9.0"
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  backend "s3" {
    bucket                      = "rf-tofu-state"
    key                         = "matrix.tfstate"
    profile                     = "scaleway"
    region                      = "nl-ams"
    endpoint                    = "https://s3.nl-ams.scw.cloud"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }
}

provider "scaleway" {
  region = "nl-ams"
}

resource "scaleway_instance_ip" "v4" {}
resource "scaleway_instance_ip" "v6" {
  type = "routed_ipv6"
}

resource "scaleway_instance_server" "this" {
  type   = "DEV1-S"
  image  = "debian_bookworm"
  ip_ids = [scaleway_instance_ip.v4.id, scaleway_instance_ip.v6.id]
  root_volume {
    delete_on_termination = false
    size_in_gb            = 100
  }
  user_data = {
    cloud-init = file("${path.module}/cloud-init.yml")
  }
}

data "scaleway_domain_zone" "scw" {
  domain = "scw.avengerpenguin.com"
}

resource "scaleway_domain_record" "matrix-a" {
  dns_zone = data.scaleway_domain_zone.scw.domain
  data     = scaleway_instance_ip.v4.address
  type     = "A"
  name     = "matrix"
}

resource "scaleway_domain_record" "matrix-aaaa" {
  dns_zone = data.scaleway_domain_zone.scw.domain
  data     = scaleway_instance_ip.v6.address
  type     = "AAAA"
  name     = "matrix"
}

output "hostname" {
  value = scaleway_domain_record.matrix-a.fqdn
}
