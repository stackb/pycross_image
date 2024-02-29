package extension

import (
	"github.com/bazelbuild/bazel-gazelle/rule"
)

func shouldGenerateAllFilesRule(rel string) bool {
	return true
}

func exampleTestFilegroupLoadInfo() rule.LoadInfo {
	return rule.LoadInfo{
		Name:    "//tools/example_test:defs.bzl",
		Symbols: []string{"example_test_filegroup"},
	}
}

func exampleTestFilegroupKinds() map[string]rule.KindInfo {
	return map[string]rule.KindInfo{
		"py_wheels": rule.KindInfo{
			MatchAny:   true,
			MergeAttrs: map[string]bool{"srcs": true},
		},
	}
}

func generateExampleTestFilegroupsRule(name string, srcs []string) *rule.Rule {
	r := rule.NewRule("example_test_filegroup", name)
	r.SetAttr("srcs", srcs)
	return r
}
