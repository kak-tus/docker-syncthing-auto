package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/hashicorp/consul/api"
)

var kv *api.KV

func main() {
	kv = getClient()

	srv := os.Getenv("SYNC_SERVICE")
	ip := os.Getenv("SYNC_IP")
	port := os.Getenv("SYNC_PORT")
	id := os.Getenv("DEVICE_ID")

	key := fmt.Sprintf("service/syncthing-auto/%s/devices/list/%s-%s", srv, ip, port)
	store(key, "1")

	key = fmt.Sprintf("service/syncthing-auto/%s/devices/%s-%s/device_id", srv, ip, port)
	store(key, id)

	key = fmt.Sprintf("service/syncthing-auto/%s/devices/%s-%s/ip", srv, ip, port)
	store(key, ip)

	key = fmt.Sprintf("service/syncthing-auto/%s/devices/%s-%s/port", srv, ip, port)
	store(key, port)

	folders := strings.Split(os.Getenv("SYNC_FOLDERS"), "\n")

	for _, val := range folders {
		val = strings.TrimSpace(val)

		if val == "" {
			continue
		}

		fld := strings.Split(val, ":")

		if len(fld) != 2 {
			continue
		}

		pathID := fld[0]
		path := fld[1]

		if pathID == "" || path == "" {
			continue
		}

		err := os.MkdirAll(path, 0755)
		if err != nil {
			panic(err)
		}

		fl := filepath.Join(path, ".stfolder")
		h, err := os.Create(fl)
		if err != nil {
			panic(err)
		}

		h.Close()

		uid, err := strconv.Atoi(os.Getenv("USER_UID"))
		if err != nil {
			panic(err)
		}
		gid, err := strconv.Atoi(os.Getenv("USER_GID"))
		if err != nil {
			panic(err)
		}

		err = os.Chown(path, uid, gid)
		if err != nil {
			panic(err)
		}

		if os.Getenv("SYNC_MASTER_MODE") == "1" {
			key = fmt.Sprintf("service/syncthing-auto/%s/folders/list/%s", srv, pathID)
			store(key, path)
		}
	}

	os.Exit(0)
}

func getClient() *api.KV {
	client, err := api.NewClient(api.DefaultConfig())
	if err != nil {
		panic(err)
	}

	kv := client.KV()
	return kv
}

func store(key string, value string) {
	data := &api.KVPair{
		Key:   key,
		Value: []byte(value),
	}

	_, err := kv.Put(data, nil)
	if err != nil {
		panic(err)
	}
}
