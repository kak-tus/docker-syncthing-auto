package main

import (
	"os"
	"time"

	"github.com/hashicorp/consul/api"
)

func main() {
	client, err := api.NewClient(api.DefaultConfig())
	if err != nil {
		panic(err)
	}

	kv := client.KV()

	ipID := os.Getenv("SYNC_IP") + "-" + os.Getenv("SYNC_PORT")
	dt := time.Now()
	srv := os.Getenv("SYNC_SERVICE")

	timeKey := "service/syncthing-auto/" + srv + "/devices/" + ipID + "/time"

	put := &api.KVPair{Key: timeKey, Value: []byte(dt.Format(time.RFC3339))}
	_, err = kv.Put(put, nil)
	if err != nil {
		panic(err)
	}

	// list, _, err := kv.List("service/syncthing-auto/"+srv+"/devices/list", nil)
	// if err != nil {
	// 	panic(err)
	// }

	// for _, val := range list {
	// 	str := strings.Split(val.Key, "/")
	// 	ip := str[len(str)-1]

	// 	timeval, _, err := kv.Get("service/syncthing-auto/"+srv+"/devices/"+ip+"/time", nil)
	// 	if err != nil {
	// 		panic(err)
	// 	}

	// 	dtOld, err := time.Parse(time.RFC3339, string(timeval.Value))
	// 	if err != nil {
	// 		panic(err)
	// 	}

	// 	if dt.Sub(dtOld).Hours() > 24 {
	// 		fmt.Println("Delete " + ip)

	// 		_, err = kv.Delete("service/syncthing-auto/"+srv+"/devices/list/"+ip, nil)
	// 		if err != nil {
	// 			panic(err)
	// 		}

	// 		_, err = kv.DeleteTree("service/syncthing-auto/"+srv+"/devices/"+ip, nil)
	// 		if err != nil {
	// 			panic(err)
	// 		}
	// 	}
	// }
}
