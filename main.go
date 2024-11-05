package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http/httputil"
	"net/url"
	"os/exec"
	"strings"

	"github.com/labstack/echo/v5"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

func main() {
	app := pocketbase.New()

	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		// Get crdt collections
		tables := map[string]any{}
		tables["todos"] = "json_extract(data, '$.user') = '{{user_id}}'"
		tablesJson, err := json.Marshal(tables)
		serverPort := "6000"
		if err != nil {
			return err
		}
		go func() {
			app.Logger().Info("Starting ws server: " + string(tablesJson))
			out, err := runCMD(*app, "dart", []string{"run", "bin/server.dart", "--tables=" + string(tablesJson), "--port=" + serverPort})
			app.Logger().Info("Server ws started: " + "port " + serverPort)
			if err != nil {
				app.Logger().Error("RunCMD ERROR: " + fmt.Sprint(err))
			}
			if out != "" {
				app.Logger().Info("RunCMD OUTPUT: " + out)
			}
		}()
		proxy := httputil.NewSingleHostReverseProxy(&url.URL{
			Scheme: "http",
			Host:   "localhost:6000",
		})
		e.Router.Any("/*", echo.WrapHandler(proxy))
		e.Router.Any("/", echo.WrapHandler(proxy))
		return nil
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}

func runCMD(app pocketbase.PocketBase, path string, args []string) (out string, err error) {
	cmd := exec.Command(path, args...)
	var b []byte
	b, err = cmd.CombinedOutput()
	out = string(b)
	app.Logger().Info(
		"RunCMD",
		"cmd", path,
		"args", strings.Join(cmd.Args[:], " "),
		"output", out,
	)
	if err != nil {
		app.Logger().Error(
			"RunCMD ERROR",
			"cmd", path,
			"args", strings.Join(cmd.Args[:], " "),
			"error", out,
		)
	}
	return
}
