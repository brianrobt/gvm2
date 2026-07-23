# gvm2

> **Status: stable for daily use (v1.3.0)**
>
> gvm2 is a community reboot of the Go Version Manager. Please file bugs and
> contributions against this repository. Production use is supported for the
> install and shell-integration paths covered by CI; advanced pkgset workflows
> may still have rough edges.

## Quick start

Install gvm2, then install and select a Go version (binary install is preferred
on a fresh machine):

```bash
bash < <(curl -s -S -L https://raw.githubusercontent.com/brianrobt/gvm2/master/binscripts/gvm-installer)
source ~/.gvm/scripts/gvm

gvm install go1.22.12        # or: gvm install "$(gvm listall --latest)"
gvm use go1.22.12 --default
go version
```

In a module directory you can omit the version — gvm2 reads `.go-version` or
`go.mod` (`toolchain` / `go` line) and maps language versions like `go 1.22` to
the latest matching patch:

```bash
gvm install -B              # install version from go.mod / .go-version
gvm use                     # select matching installed version
```

Common commands (nvm-style workflow):

| Goal | Command |
|------|---------|
| List available versions | `gvm listall` |
| Latest stable name only | `gvm listall --latest` |
| Install a version | `gvm install go1.22.12` |
| Install from project files | `gvm install` (or `gvm install -B`) |
| Switch version | `gvm use go1.22.12` |
| Switch from project files | `gvm use` |
| List installed versions | `gvm list` |
| Per-directory auto-switch | commit a `.go-version` (and optional `.go-pkgset`) |

`gvm listall` annotates `latest`, `beta`, and `rc` (Go has no official LTS). Use
`gvm listall --porcelain` for script-friendly names only.

Set `GVM_NO_CD=1` before sourcing gvm to disable the `cd` auto-switch hook
(performance / autofs).

## About this reboot

[gvm](https://github.com/moovweb/gvm) (Go Version Manager) was created by Josh
Bussdieker at [Moovweb](https://www.moovweb.com) and later maintained by
[Benjamin Knigge](https://github.com/BenKnigge). The upstream repository is no
longer actively maintained — see [moovweb/gvm#536](https://github.com/moovweb/gvm/issues/536).

**gvm2** continues that work under a new name so the original project can be
resumed by its prior maintainers if they choose, without conflicting with this
effort. This repository is an independent continuation, not affiliated with
Moovweb.

The CLI command remains `gvm` and the default install directory remains
`~/.gvm` for drop-in compatibility with existing setups.

### Issue triage (from moovweb/gvm)

The upstream repo has ~200 open issues and ~30 open pull requests. Initial
triage groups the backlog into these priorities:

| Priority | Area | Examples | Status in gvm2 |
|----------|------|----------|----------------|
| P0 | Shell integration (`cd`, PATH, zsh) | [#527](https://github.com/moovweb/gvm/issues/527), [#528](https://github.com/moovweb/gvm/issues/528), [#515](https://github.com/moovweb/gvm/issues/515) | Fixed in 1.1.0 |
| P1 | Install / bootstrap | [#530](https://github.com/moovweb/gvm/issues/530), [#480](https://github.com/moovweb/gvm/issues/480) | Fixed in 1.1.0 |
| P2 | UX / docs / ergonomics | [#517](https://github.com/moovweb/gvm/issues/517), [#516](https://github.com/moovweb/gvm/issues/516) | Fixed in 1.2.0 ([#4](https://github.com/brianrobt/gvm2/issues/4)) |
| P3 | Features (progress bars, worktrees, auto-detect `go.mod`) | [#514](https://github.com/moovweb/gvm/issues/514), [#523](https://github.com/moovweb/gvm/issues/523) | `go.mod` auto-detect in 1.3.0 ([#10](https://github.com/brianrobt/gvm2/issues/10)); progress / worktrees still backlog |

Tracked here: [brianrobt/gvm2/issues](https://github.com/brianrobt/gvm2/issues).

Pull requests and other contributions are very much appreciated.

## Features

* Install/Uninstall Go versions with `gvm install [tag]` where tag is "go1.22.12", "go1", "weekly.2011-11-08", or "tip"
* Omit the version on `gvm install` / `gvm use` to resolve from `.go-version` or `go.mod`
* List available versions with `gvm listall` (annotations + `--latest` / `--porcelain`)
* List added/removed files in GOROOT with `gvm diff`
* Manage GOPATHs with `gvm pkgset [create/use/delete] [name]`. Use `--local` as `name` to manage repository under local path (`/path/to/repo/.gvm_local`).
* Cache a clean copy of the latest Go source for multiple version installs.
* Link project directories into GOPATH
* Auto-switch on `cd` via `.go-version` / `.go-pkgset` (optional `GVM_NO_CD=1` to disable)

## Background

When we started developing in Go mismatched dependencies and API changes plagued our build process and made it extremely difficult to merge with other peoples changes.

After nuking my entire GOROOT several times and rebuilding I decided to come up with a tool to oversee the process. It eventually evolved into what gvm is today.

## Installing

To install:

1. Install [Bison](https://www.gnu.org/software/bison/) (needed for source builds):

   ```bash
   sudo apt-get install bison
   ```

2. Install gvm2:

   ```bash
   bash < <(curl -s -S -L https://raw.githubusercontent.com/brianrobt/gvm2/master/binscripts/gvm-installer)
   ```

Or if you are using zsh just change `bash` with `zsh`.

## Installing Go

On a machine with no Go installed, prefer a binary install (default when no
`go` is on `PATH`):

```bash
gvm install go1.22.12
gvm use go1.22.12 [--default]
```

Once this is done Go will be in the path and ready to use. `$GOROOT` and `$GOPATH` are set automatically.

Additional options can be specified when installing Go:

```
Usage: gvm install [version] [options]
    -s,  --source=SOURCE      Install Go from specified source.
    -n,  --name=NAME          Override the default name for this version.
    -pb, --with-protobuf      Install Go protocol buffers.
    -b,  --with-build-tools   Install package build tools.
    -B,  --binary             Only install from binary.
         --prefer-binary      Attempt a binary install, falling back to source.
    -h,  --help               Display this message.
```

### Compiling from source (Go 1.5+)

Go 1.5+ removed the C compilers from the toolchain and [replaced][compiler_note]
them with one written in Go. gvm2 handles this automatically: when a source
install needs a bootstrap compiler, it finds a compatible installed version or
downloads a binary bootstrap for you. You do not need a pre-existing Go install
or a manual go1.4 chain.

### A Note on ARMv6 and ARMv7 architectures (32 bit)

Binary versions for ARMv6 architecture are available
[starting from Go 1.6](https://go.dev/dl/#go1.6). gvm2 will pull a compatible
binary to bootstrap source installations on ARM as well when needed.

[compiler_note]: https://docs.google.com/document/d/1OaatvGhEAq7VseQ9kkavxKNAfepWy2yhPUBs96FGV28/edit

## List Go Versions

To list all installed Go versions (the current version is prefixed with `=>`):

```bash
gvm list
```

To list Go versions available for download (annotated with `latest` / `beta` / `rc`):

```bash
gvm listall
gvm listall --latest      # print only the latest stable tag
gvm listall --porcelain   # names only, for scripts
```

## Uninstalling

To completely remove gvm and all installed Go versions and packages:

```bash
gvm implode
```

If that doesn't work see the troubleshooting steps at the bottom of this page.

## Mac OS X Requirements

* Install Xcode Command Line Tools from the App Store.

```bash
xcode-select --install
```

## Linux Requirements

### Debian/Ubuntu

```bash
sudo apt-get install curl git make binutils bison gcc build-essential
```

### Redhat/Centos

```bash
sudo yum install curl git make bison gcc glibc-devel
```

## FreeBSD Requirements

```bash
sudo pkg_add -r bash
sudo pkg_add -r git
```

## Vendoring Native Code and Dependencies

GVM supports vendoring package set-specific native code and related
dependencies, which is useful if you need to qualify a new configuration
or version of one of these dependencies against a last-known-good version
in an isolated manner.  Such behavior is critical to maintaining good release
engineering and production environment hygiene.

As a convenience matter, GVM will furnish the following environment variables to
aid in this manner if you want to decouple your work from what the operating
system provides:

1. `${GVM_OVERLAY_PREFIX}` functions in a manner akin to a root directory
   hierarchy suitable for auto{conf,make,tools} where it could be passed in
   to `./configure --prefix=${GVM_OVERLAY_PREFIX}` and not conflict with any
   existing operating system artifacts and hermetically be used by your
   workspace.  This is suitable to use with `C{PP,XX}FLAGS` and `LDFLAGS`, but you will have
   to manage these yourself, since each tool that uses them is different.

2. `${PATH}` includes `${GVM_OVERLAY_PREFIX}/bin` so that any tools you
   manually install will reside there, available for you.

3. `${LD_LIBRARY_PATH}` includes `${GVM_OVERLAY_PREFIX}/lib` so that any
   runtime library searching can be fulfilled there on FreeBSD and Linux.

4. `${DYLD_LIBRARY_PATH}` includes `${GVM_OVERLAY_PREFIX}/lib` so that any
   runtime library searching can be fulfilled there on Mac OS X.

5. `${PKG_CONFIG_PATH}` includes `${GVM_OVERLAY_PREFIX}/lib/pkgconfig` so
   that `pkg-config` can automatically resolve any vendored dependencies.

Recipe for success:

```bash
gvm use go1.22.12
gvm pkgset use current-known-good
# Let's assume that this includes some C headers and native libraries, which
# Go's CGO facility wraps for us.  Let's assume that these native
# dependencies are at version V.
gvm pkgset create trial-next-version
# Let's assume that V+1 has come along and you want to safely trial it in
# your workspace.
gvm pkgset use trial-next-version
# Do your work here replicating current-known-good from above, but install
# V+1 into ${GVM_OVERLAY_PREFIX}.
```

See `examples/native` for a working example.

## Troubleshooting

If gvm's state gets mixed up, `rm -rf ~/.gvm` removes it completely. Set
`GVM_NO_CD=1` before sourcing gvm if the `cd` hook conflicts with autofs or is
too slow for your environment.
