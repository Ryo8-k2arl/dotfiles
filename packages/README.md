# Package manifests

System packages are defined outside the chezmoi source state. Chezmoi deploys
files under `home/`; it does not decide which distribution package manager to
run.

- `common/`: names shared by supported distributions
- `arch/`: Arch Linux package groups
- `alma/`: AlmaLinux package groups

Blank lines and lines beginning with `#` are comments. Review a manifest before
passing it to `pacman`, an AUR helper, or `dnf`; package installation remains an
explicit system-administration action.
