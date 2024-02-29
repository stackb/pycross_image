package extension

import (
	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/rule"
)

// extConfig represents the config extension for the this extension.
type extConfig struct {
	// config is the parent gazelle config.
	config *config.Config
}

// newExtConfig initializes a new extConfig.
func newExtConfig(config *config.Config) *extConfig {
	return &extConfig{
		config: config,
	}
}

// getExtConfig returns the config.  Can be nil.
func getExtConfig(config *config.Config) *extConfig {
	if existingExt, ok := config.Exts[langName]; ok {
		return existingExt.(*extConfig)
	} else {
		return nil
	}
}

// getOrCreateExtConfig either inserts a new config into the map under the
// language name or replaces it with a clone.
func getOrCreateExtConfig(config *config.Config) *extConfig {
	var cfg *extConfig
	if existingExt, ok := config.Exts[langName]; ok {
		cfg = existingExt.(*extConfig).Clone()
	} else {
		cfg = newExtConfig(config)
	}
	config.Exts[langName] = cfg
	return cfg
}

// Clone copies this config to a new one.
func (c *extConfig) Clone() *extConfig {
	clone := newExtConfig(c.config)
	return clone
}

// parseDirectives is called in each directory visited by gazelle.  The relative
// directory name is given by 'rel' and the list of directives in the BUILD file
// are specified by 'directives'.
func (c *extConfig) parseDirectives(rel string, directives []rule.Directive) (err error) {
	return
}
