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

      env {
        PORT = "${NOMAD_PORT_http}"
      }

      service {
        port = "http"
        tags = ["frontend", "urlprefix-/"]
        
        check {
          type = "http"
          path = "/"
          interval = "5s"
          timeout = "2s"
        }

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