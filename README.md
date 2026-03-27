# setup-ci

An action to set up the toolchain on CI used for building spatial-model-editor and its dependencies.

## Supported platforms

- `OS=linux`
  - Linux (X64)
  - clang 19
- `OS=linux-arm64`
  - Linux (ARM64)
  - clang 19
- `OS=osx-arm64`
  - macOS (ARM64 only)
  - xcode 16.1
  - `MACOSX_DEPLOYMENT_TARGET=13`
- `OS=win64`
  - Windows (X64)
  - Visual Studio 2022 MSVC
  - MSVC toolset `14.44`
- `OS=win64-arm64`
  - Windows (ARM64)
  - Visual Studio 2022 MSVC
  - MSVC toolset `14.44`

## Inputs

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

You can also install additional platform-native packages via `extra-deps`:

- Linux: apt package names
- macOS: Homebrew formula names
- Windows: Chocolatey package names

```yaml
      - uses: spatial-model-editor/setup-ci@2024.01.01
        with:
          extra-deps: libfoo-dev
```

You can also specify an optional build tag to download specific builds of libs, currently only `_tsan` is supported

```yaml
      - uses: spatial-model-editor/setup-ci@2024.01.01
        with:
          sme_deps_common: 2024.01.05
          build_tag: _tsan
```

## Environment variables

This action exports the following environment variables for subsequent workflow steps:

- `CCACHE_VERSION`: ccache version installed by the action, currently `4.12.1`
- `PYTHON_VERSION`: Python version installed by the action, currently `3.12`
- `MSVC_TOOLSET`: Windows MSVC toolset version used by the action, currently `14.44`
- `TARGET_TRIPLE`: target platform triple for the current runner
- `HOST_TRIPLE`: host platform triple for the current runner
- `OS`: one of `linux`, `linux-arm64`, `osx-arm64`, `win64`, or `win64-arm64`
- `CCACHE_ARCH`: ccache archive architecture, `x86_64` or `aarch64`
- `INSTALL_PREFIX`: `/opt/smelibs` on Linux/macOS, `c:\smelibs` on Windows
- `SUDO_CMD`: `sudo` on Linux/macOS, empty on Windows
- `PYTHON_EXE`: `python`
- `CC`: `clang` on Linux/macOS, `cl` on Windows
- `CXX`: `clang++` on Linux/macOS, `cl` on Windows
- `MACOSX_DEPLOYMENT_TARGET`: `13` on macOS ARM64 runners only

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
