max_stale = "2m"

template {
  source = "/etc/config.xml.template"
  destination = "/home/user/config/config.xml"
}

exec {
  command = "/syncthing/syncthing -home /home/user/config"
  splay = "60s"
  kill_timeout = "20s"
}
