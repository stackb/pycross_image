package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"strings"
)

func generateTest(c *Config) error {
	f, err := os.Create(c.TestOut)
	if err != nil {
		return fmt.Errorf("create %s: %v", c.TestOut, err)
	}
	defer f.Close()

	fmt.Fprintln(f, testHeader)
	fmt.Fprintln(f, c.TestContent)

	fmt.Fprintln(f, "var txtar=`")

	fmt.Fprintf(f, "-- WORKSPACE --\n")

	data, err := os.ReadFile(c.WorkspaceIn)
	if err != nil {
		return fmt.Errorf("read %q: %v", c.WorkspaceIn, err)
	}
	if _, err := f.Write(data); err != nil {
		return fmt.Errorf("write %q: %v", c.WorkspaceIn, err)
	}

	// seek out the WORKSPACE.in file and append it now such that the WORKSPACE
	// in the testdata is concatenated with the config.WorkspaceIn.
	for _, src := range c.Files {
		if filepath.Base(src) != "WORKSPACE.in" {
			continue
		}
		data, err := os.ReadFile(src)
		if err != nil {
			return fmt.Errorf("read %q: %v", src, err)
		}
		f.WriteString("\n")
		if _, err := f.Write(data); err != nil {
			return fmt.Errorf("write: %v", err)
		}
		break
	}

	for _, src := range c.Files {
		dst := mapFilename(src)
		if dst == "" {
			continue
		}

		dstFilename := filepath.Base(dst)
		if c.StripPrefix != "" {
			dstFilename = stripRel(c.StripPrefix, dst)
		}

		fmt.Fprintf(f, "-- %s --\n", dstFilename)

		data, err := os.ReadFile(src)
		if err != nil {
			return fmt.Errorf("read %q: %v", src, err)
		}
		if _, err := f.Write(data); err != nil {
			return fmt.Errorf("write %q: %v", dst, err)
		}
		f.WriteString("\n")
	}

	fmt.Fprintln(f, "`")

	return nil
}

func mapFilename(in string) string {
	dir := filepath.Dir(in)
	base := filepath.Base(in)

	switch base {
	case "WORKSPACE.in":
		return ""
	case "BUILD.in":
		return filepath.Join(dir, "BUILD.bazel")
	}

	return in
}

func printFileBlock(name, syntax, filename string, out io.Writer) error {
	fmt.Fprintf(out, "~~~%s\n", syntax)
	data, err := os.ReadFile(filename)
	if err != nil {
		log.Panicf("%s: read %q: %v", name, filename, err)
	}
	if _, err := out.Write(data); err != nil {
		log.Panicf("%s: write %q: %v", name, filename, err)
	}
	fmt.Fprintf(out, "~~~\n\n")

	return nil
}

// stripRel removes the rel prefix from a filename (if has matching prefix)
func stripRel(rel string, filename string) string {
	if !strings.HasPrefix(filename, rel) {
		return filename
	}
	filename = filename[len(rel):]
	return strings.TrimPrefix(filename, "/")
}
