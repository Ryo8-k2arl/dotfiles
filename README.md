# dotfiles

## Rust development with LazyVim

The Rust toolchain is managed by the existing Cargo environment. Neovim tooling is declared entirely through LazyVim and Mason:

- Cargo environment: `rustc`, Cargo, Clippy, rustfmt, and the Rust standard library
- Mason: rust-analyzer and codelldb
- LazyExtras: Rust language support, tests, and debugging
- `lazy-lock.json`: reproducible plugin versions

With the Rust toolchain already available, start Neovim once. LazyVim installs the plugins and Mason installs the editor tools automatically:

```sh
nvim
```

Open a Rust project at its Cargo workspace root. Useful commands and keymaps include:

- `:LspInfo`: check the rust-analyzer connection
- `:Mason`: check rust-analyzer and codelldb installation
- `:LazyFormatInfo`: check rustfmt formatting
- `<leader>cR`: Rust code actions
- `<leader>tt`: run tests in the current file
- `<leader>tr`: run the nearest test
- `<leader>dr`: select a Rust debug target
