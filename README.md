# Drake-OpenSUSE-Integration

### Usage

- `docker-compose build --no-cache`
- `docker-compose run drake-opensuse`
- (After usage) `docker-compose down --remove-orphans`

### Documentation

- Fixed gcc-fortran nasm by just installing it with Zypper
- Fixed lapack and blas by adding made up .pc files
- Fixed fmt, spdlog by building from source from GitHub repositories
- Fixed native python version 3.6 with Pyenv 3.10

#### Problem with mumps
#### https://stackoverflow.com/questions/78114963/integration-of-drake-to-opensuse-error-in-external-mumps-internal-build-bazel

### Changed ownership of the drake folder to docker  container's user and group id for smoother operation in docker container


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

