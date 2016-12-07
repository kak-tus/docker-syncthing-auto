max_stale = "2m"

template {
  source = "/home/user/config.xml.template"
  destination = "/home/user/.config/syncthing/config.xml"
}

exec {
  command = "syncthing"
  splay = "60s"
}
