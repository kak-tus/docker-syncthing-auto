max_stale = "2m"

template {
  source = "/etc/config.xml.template"
  destination = "/home/user/config/config.xml"
}

exec {
  command = "/usr/local/bin/start.sh"
  splay = "300s"
  kill_timeout = "20s"
}
