# Drake-OpenSUSE-Integration

### Usage

- (`sudo chown -R 499:486 drake`) (you may have to change this, see below)
- `docker-compose build --no-cache`
- `docker-compose run drake-opensuse`
- (After usage) `docker-compose down --remove-orphans`

### Documentation


- fixed ownership issues with git-folder drake (see below)
- fixed gcc-fortran nasm by just installing it with Zypper
- fixed lapack and blas by adding made up .pc files
- fixed fmt, spdlog by building from source from GitHub repositories
- fixed native python version 3.6 with Pyenv 3.10

#### Problem with mumps - fixed
- https://stackoverflow.com/questions/78114963/integration-of-drake-to-opensuse-error-in-external-mumps-internal-build-bazel

-> In `tools/workspace/mumps_internal/repository.bzl` I changed
`repo_ctx.symlink("/usr/include/mumps/" + hdr, "include/" + hdr) # Changed this for OpenSUSE integration`

- fixed gcc problem by installing gcc 10
- fixed /usr/share/java/jchart2d.jar file issue by downloading it with wget
- fixed missing PyYAML by installing it
- fixed missing llvm-clang packages by just installing it with Zypper


####  Problem with spdlog and fmt - (seems to be fixed - might resurface)
https://stackoverflow.com/questions/78122252/integration-of-drake-to-opensuse-build-error-with-spdlog-and-fmt

- RuntimeError: Library file /usr/lib/x86_64-linux-gnu/libclang-14.so does NOT exist

### Docker stuff

#### Changed ownership of the drake folder to docker container's user and group id for smoother operation in docker container


#### Before change


```
dan@SurfBoard3:~/Projects/Drake-OpenSUSE-Integration$ ls -ld drake
drwxrwxr-x 23 dan dan 4096 Mär  5 11:20 drake
```

#### change

- `dan@SurfBoard3:~/Projects/Drake-OpenSUSE-Integration$ sudo chown -R 499:486 drake
`

#### After change

```
dan@SurfBoard3:~/Projects/Drake-OpenSUSE-Integration$ ls -ld drake
drwxrwxr-x 23 499 486 4096 Mär  5 11:20 drake
```

- I configured git accordingly

`git config --global --add safe.directory /home/dan/Projects/Drake-OpenSUSE-Integration/drake`

