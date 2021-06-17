job "frontend" {
  datacenters = ["dc1"]
  type = "service"

  group "frontend" {
    count = 1

    task "frontend" {
      driver = "docker"
      config {
        image = "thedojoseries/frontend"
      }

      resources {
        network {
          port "http" {
            static = 8080
          }
        }
      }
    }
  }
}