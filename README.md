# pycross_image

`pycross_image` provides starlark rules for building container images for python
applications with bazel.

You can use the rules directly from this repo, or simply as examples and
copy/paste them into your own project.


Given a pycross_oci_image rule `//my:image` wrapping a py_binary rule `//my:app`, the following targets are defined:

| Kind                            | Label                        | Description                                              |
|---------------------------------|------------------------------|----------------------------------------------------------|
| oci_image rule                  | //my:image                   | The target container image                               |
| oci_tarball rule                | //my:image.tar               | Tarball rule that can be `bazel run` to `docker load` it |
| tar rule                        | //my:image.app_layer         | Image layer for the application code                     |
| tar rule                        | //my:image.packages_layer    | Image layer for site-packages                            |
| tar rule                        | //my:image.interpreter_layer | Image layer for the python3 interpreter                  |
| platform_transition_binary rule | //my:xapp                    | The transitioned "cross" py_binary                       |
| py_binary rule                  | //my:app                     | The source py_binary app                                 |

`docker inspect` yields the following (subset):

```json
[
    {
        "RepoTags": [
            "my/app:latest",
        ],
        "Config": {
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt",
                "LANG=C.UTF-8"
            ],
            "Cmd": [
                "app"
            ],
            "WorkingDir": "/my/xapp",
            "Entrypoint": [
                "/my/xapp/app.runfiles/python_x86_64-unknown-linux-gnu/bin/python3"
            ],
        },
        "Architecture": "amd64",
        "Os": "linux"
    }
]
```

