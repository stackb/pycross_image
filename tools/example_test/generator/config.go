package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type Config struct {
	Name        string
	Label       string
	TestOut     string
	TestContent string
	WorkspaceIn string
	StripPrefix string
	Files       []string
}

// fromJSON constructs a Config struct from the given filename that contains a
// JSON.
func fromJSON(filename string) (*Config, error) {
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("read: %w", err)
	}

	var config Config
	if err := json.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("unmarshal: %w", err)
	}

	return &config, nil
}
