template {
    source = "/etc/consul-template.d/templates/haproxy.ctmpl"
    destination = "/etc/haproxy/haproxy.cfg"
    command = "service haproxy reload"
}

wait {
    min = "2s"
    max = "10s"
}
