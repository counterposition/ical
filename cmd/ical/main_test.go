package main

import (
	"runtime/debug"
	"testing"
)

func TestResolveVersion(t *testing.T) {
	tests := []struct {
		name      string
		injected  string
		buildInfo *debug.BuildInfo
		want      string
	}{
		{
			name:      "linker version wins",
			injected:  "v0.100.1",
			buildInfo: &debug.BuildInfo{Main: debug.Module{Version: "v0.100.0"}},
			want:      "v0.100.1",
		},
		{
			name:      "go install module version replaces dev",
			injected:  "dev",
			buildInfo: &debug.BuildInfo{Main: debug.Module{Version: "v0.100.1"}},
			want:      "v0.100.1",
		},
		{
			name:      "local development build stays dev",
			injected:  "dev",
			buildInfo: &debug.BuildInfo{Main: debug.Module{Version: "(devel)"}},
			want:      "dev",
		},
		{
			name:     "missing build info keeps injected value",
			injected: "dev",
			want:     "dev",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := resolveVersion(tt.injected, tt.buildInfo); got != tt.want {
				t.Fatalf("resolveVersion() = %q, want %q", got, tt.want)
			}
		})
	}
}
