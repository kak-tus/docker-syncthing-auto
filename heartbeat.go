package main

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/hashicorp/consul/api"
)

var kv *api.KV
var dtLimit time.Time
var dt time.Time
var srv string

func main() {
	client, err := api.NewClient(api.DefaultConfig())
	if err != nil {
		panic(err)
	}

	kv = client.KV()

	ipID := os.Getenv("SYNC_IP") + "-" + os.Getenv("SYNC_PORT")
	dt = time.Now()
	srv = os.Getenv("SYNC_SERVICE")
	dtLimit = dt.Add(-time.Duration(12 * time.Hour))

	timeKey := "service/syncthing-auto/" + srv + "/devices/" + ipID + "/time"

	saveTime(timeKey, dt)

	list, _, err := kv.List("service/syncthing-auto/"+srv+"/devices/list", nil)
	if err != nil {
		panic(err)
	}

	for _, val := range list {
		str := strings.Split(val.Key, "/")
		ip := str[len(str)-1]

		processItem(ip)
	}

	list, _, err = kv.List("service/syncthing-auto/"+srv+"/devices", nil)
	if err != nil {
		panic(err)
	}

	ips := make(map[string]bool)

	for _, val := range list {
		str := strings.Split(val.Key, "/")
		ip := str[4]

		if ip == "list" || ips[ip] {
			continue
		}

		ips[ip] = true
		processItem(ip)
	}
}

func processItem(ip string) {
	key := "service/syncthing-auto/" + srv + "/devices/" + ip + "/time"

	timeval, _, err := kv.Get(key, nil)
	if err != nil {
		panic(err)
	}

	if timeval == nil {
		saveTime(key, dt)
		return
	}

	dtOld, err := time.Parse(time.RFC3339, string(timeval.Value))
	if err != nil {
		panic(err)
	}

	if dtOld.Before(dtLimit) {
		fmt.Println("Delete " + ip)

		_, err = kv.Delete("service/syncthing-auto/"+srv+"/devices/list/"+ip, nil)
		if err != nil {
			println(err)
		}

		_, err = kv.DeleteTree("service/syncthing-auto/"+srv+"/devices/"+ip, nil)
		if err != nil {
			println(err)
		}
	}
}

func saveTime(key string, dt time.Time) {
	put := &api.KVPair{Key: key, Value: []byte(dt.Format(time.RFC3339))}
	_, err := kv.Put(put, nil)
	if err != nil {
		panic(err)
	}
}
