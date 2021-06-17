job "frontend" {
  datacenters = ["dc1"]
  type = "service"

  group "frontend" {
    task "frontend" {
      driver = "docker"
      config {
        image = "thedojoseries/frontend"
      }

      resources {
      }
    }
    scaling {
      enabled = true
      min = 5
      max = 10
      policy {
      }
    }
    network {
      port "http" {
        static = 8080
      }
    }
  }
}