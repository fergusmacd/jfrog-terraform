# Create a new Artifactory local repository called my-local
resource "artifactory_local_repository" "mvn_local" {
  key             = "mvn-local"
  package_type    = "maven"
  repo_layout_ref = "maven-2-default"
  description     = "Main repo for mirroring and uploading from build server"
  notes           = "Note to see what they do"
}
# https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/r/artifactory_local_repository.html.markdown
resource "artifactory_local_repository" "docker_dev_local" {
  key                = "docker-dev-local"
  package_type       = "docker"
  description        = "Repo for uploading images to for dev (non-prod environments)"
  notes              = "This repo should be pruned to avoid maintaining old images."
  docker_api_version = "V2"
  max_unique_tags    = 10
}

# https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/r/artifactory_virtual_repository.html.markdown
resource "artifactory_virtual_repository" "docker_dev_virtual" {
  key          = "docker-dev-virtual"
  package_type = "docker"
  description  = "Virtual repo for all images to be downloaded from for dev."
  repositories = [
    "${artifactory_local_repository.docker_dev_local.key}",
    "${artifactory_remote_repository.docker_remote.key}"
  ]
}

resource "artifactory_local_repository" "docker_stg_local" {
  key                = "docker-stg-local"
  package_type       = "docker"
  description        = "Repo for promoting images from dev for using in stg environments"
  notes              = "This repo should be pruned to avoid maintaining old images."
  docker_api_version = "V2"
  max_unique_tags    = 10
}

resource "artifactory_virtual_repository" "docker_stg_virtual" {
  key          = "docker-stg-virtual"
  package_type = "docker"
  description  = "Virtual repo for all images to be downloaded from for stg."
  repositories = [
    "${artifactory_local_repository.docker_stg_local.key}",
    "${artifactory_remote_repository.docker_remote.key}"
  ]
}


resource "artifactory_local_repository" "docker_prod_local" {
  key                = "docker-prod-local"
  package_type       = "docker"
  description        = "Repo for promoting images from stg for using in prod environments"
  notes              = "This repo should be not pruned as it is a record of what is in prod."
  docker_api_version = "V2"
  max_unique_tags    = 10
}

resource "artifactory_virtual_repository" "docker_prod_virtual" {
  key          = "docker-prod-virtual"
  package_type = "docker"
  description  = "Virtual repo for all images to be downloaded from for prod."
  repositories = [
    "${artifactory_local_repository.docker_prod_local.key}",
    "${artifactory_remote_repository.docker_remote.key}"
  ]
}

# https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/r/artifactory_remote_repository.html.markdown
resource "artifactory_remote_repository" "docker_remote" {
  key                         = "docker-remote"
  package_type                = "docker"
  url                         = "https://registry-1.docker.io/"
  description                 = "Repo for proxy to docker repos"
  enable_token_authentication = true
}

# https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/r/artifactory_virtual_repository.html.markdown
resource "artifactory_virtual_repository" "docker_all_virtual" {
  key                     = "docker-all-virtual"
  package_type            = "docker"
  description             = "Virtual external repo for all images to be downloaded from."
  default_deployment_repo = "${artifactory_local_repository.docker_dev_local.key}"
  repositories = [
    "${artifactory_local_repository.docker_dev_local.key}",
    "${artifactory_local_repository.docker_stg_local.key}",
    "${artifactory_local_repository.docker_prod_local.key}",
    "${artifactory_remote_repository.docker_remote.key}"
  ]
}
