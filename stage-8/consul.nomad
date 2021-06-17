job "consul" {
    datacenters = ["dc1"]
    type = "service"

    group "consul" {
        task "consul" {
            driver = "exec"
            artifact {
                source      = "https://releases.hashicorp.com/consul/1.9.6/consul_1.9.6_linux_amd64.zip"
            }
            config {
                command = "consul"
                args = ["agent", "-dev"]
            }
        }
        count = 1
    }
}