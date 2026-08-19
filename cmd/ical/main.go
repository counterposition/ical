package main

import (
	"fmt"
	"os"
	"runtime"
	"runtime/debug"

	"github.com/counterposition/ical/cmd/ical/commands"
)

// Set by ldflags at build time.
var (
	version = "dev"
	commit  = "none"
	date    = "unknown"
)

func main() {
	if runtime.GOOS != "darwin" {
		fmt.Fprintln(os.Stderr, "ical requires macOS")
		os.Exit(1)
	}

	buildInfo, _ := debug.ReadBuildInfo()
	commands.SetVersionInfo(resolveVersion(version, buildInfo), commit, date)
	if err := commands.Execute(); err != nil {
		os.Exit(1)
	}
}

func resolveVersion(injected string, buildInfo *debug.BuildInfo) string {
	if injected != "" && injected != "dev" {
		return injected
	}
	if buildInfo != nil && buildInfo.Main.Version != "" && buildInfo.Main.Version != "(devel)" {
		return buildInfo.Main.Version
	}
	return injected
}
