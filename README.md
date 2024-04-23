# setup-ci

An action to set up the toolchain on CI used for building spatial-model-editor and its dependencies.

- ubuntu-20.04 (X64)
  - clang 18
  - ninja
- macos-13 (X64)
  - xcode 14.3
  - MACOSX_DEPLOYMENT_TARGET=11
  - ninja
- macos-14 (ARM64)
  - xcode 14.3
  - MACOSX_DEPLOYMENT_TARGET=11
  - ninja
- windows-2022 (X64)
  - msys2 mingw gcc (latest version, currently 13)
  - msys2 mingw ninja

To use the latest version:

```yaml
      - uses: spatial-model-editor/setup-ci@latest
```

To use a specific tag:

```yaml
      - uses: spatial-model-editor/setup-ci@2024.01.01
```

## Making a new release

To make a new release of this action, the commit should be tagged with a new tag of the date in form `YYYY.MM.DD`.

Additionally the `latest` tag should be moved to the same commit, so that workflows using this tag always get the latest version.

e.g.

```bash
git commit -am "update clang to 18"
git push
git tag 2024.01.01
git push origin 2024.01.01
git tag -f latest
git push origin -f latest
```
