max_stale = "2m"

deduplicate {
  enabled = true
  prefix = "service/syncthing-auto/dedup/"
}

template {
  source = "/home/user/config.xml.template"
  destination = "/home/user/.config/syncthing/config.xml"
}

exec {
  command = "syncthing"
  splay = "60s"
}
