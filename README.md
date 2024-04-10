# setup-ci

An action to set up the toolchain on CI used for building spatial-model-editor and its dependencies.

- ubuntu-20.04
  - clang 18
  - ninja
- macos-13
  - xcode 14.3
  - MACOSX_DEPLOYMENT_TARGET=11
  - ninja
- windows-2022
  - msys2 mingw gcc (latest version, currently 13)
  - msys2 mingw ninja

To use:

```yaml
      - uses: spatial-model-editor/setup-ci@v1
```

When a breaking change is made the version tag should be incremented here and in the workflows that use this action.
