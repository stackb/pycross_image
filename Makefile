.PHONY: pdm_sync
pdm_sync:
	bazel run //bazel/tools/pdm -- sync
	rm -rf .venv

.PHONY: pdm_lock
pdm_lock:
	bazel run //bazel/tools/pdm -- lock --static-urls
	rm -rf .venv

.PHONY: example_oci_pdm_add
example_oci_pdm_add:
	PDM_PROJECT=$(PWD)/example/oci bazel run //bazel/tools/pdm -- add grpclib
	rm -rf example/oci/.venv
