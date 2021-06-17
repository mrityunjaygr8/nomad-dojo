job "frontend" {
  datacenters = ["dc1"]
  type = "service"

  group "frontend" {
    task "frontend" {
      driver = "docker"
      config {
        image = "thedojoseries/frontend"
        ports = ["http"]
      }


      resources {
      }
    }
    scaling {
      enabled = true
      min = 2
      max = 10
      policy {
      }
    }
    network {
      port "http" {
      }
    }
  }
}