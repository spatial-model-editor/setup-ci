# setup-ci

An action to set up the toolchain on CI used for building spatial-model-editor and its dependencies.

- `OS=linux`
  - ubuntu-22.04 (X64)
  - clang 18
  - clang 19
- `OS=osx`
  - macos-13 (X64)
  - xcode 15.2
  - `MACOSX_DEPLOYMENT_TARGET=12`
- `OS=osx-arm64`
  - macos-14 (ARM64)
  - xcode 16.1
  - `MACOSX_DEPLOYMENT_TARGET=12`
- `OS=win64-mingw`
  - windows-2022 (X64)
  - msys2 mingw gcc (latest version, 14 at time of writing)

To use the latest version of this action:

```yaml
      - uses: spatial-model-editor/setup-ci@latest
```

To use a specific tag:

```yaml
      - uses: spatial-model-editor/setup-ci@2024.01.01
```

To also download pre-compiled dependencies, set the version tag or "latest":

```yaml
      - uses: spatial-model-editor/setup-ci@2024.01.01
        with:
          sme_deps_common: 2024.01.05
```

If multiple jobs have the same id (e.g. when using matrix strategy) then an optional `cache_id` can be supplied to avoid "cache already exists" errors:

```yaml
      - uses: spatial-model-editor/setup-ci@2024.01.01
        with:
          cache_id: my-unique-job-id
```

You can also specify an optional build tag to download specific builds of libs, currently only `_tsan` is supported

```yaml
      - uses: spatial-model-editor/setup-ci@2024.01.01
        with:
          sme_deps_common: 2024.01.05
          build_tag: _tsan
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
