# ─────────────────────────────────────────────
# dotfiles Makefile
# ─────────────────────────────────────────────

# dotfiles のルートディレクトリ
DOTFILES_DIR   := $(shell pwd)
CONFIG_DIR     := $(DOTFILES_DIR)/.config
TARGET_CONFIG  := $(HOME)/.config
ZSHENV_SOURCE  := $(DOTFILES_DIR)/.zshenv
ZSHENV_TARGET  := $(HOME)/.zshenv

# ─────────────────────────────────────────────
.PHONY: all install uninstall

all: install

# ─────────────────────────────────────────────
.PHONY: install
install:
	@echo "→ Installing dotfiles..."
	@if [ -e "$(TARGET_CONFIG)" ] && [ ! -L "$(TARGET_CONFIG)" ]; then \
		echo "  Backing up existing ~/.config → ~/.config.backup"; \
		mv "$(TARGET_CONFIG)" "$(TARGET_CONFIG).backup"; \
	fi
	@ln -sfn "$(CONFIG_DIR)" "$(TARGET_CONFIG)"
	@echo "  Linked: $(TARGET_CONFIG) → $(CONFIG_DIR)"
	@ln -sfn "$(ZSHENV_SOURCE)" "$(ZSHENV_TARGET)"
	@echo "  Linked: $(ZSHENV_TARGET) → $(ZSHENV_SOURCE)"
	@echo
	@echo "✔︎ Installation complete!"
	@echo ""
	@echo "Next:"
	@echo "	1. Add .env and set environment variables."
	@echo "	2. Add ~/.config/git/user.local and set up user information."
	@echo ""
	@echo "  → Please restart your shell to apply changes."

# ─────────────────────────────────────────────
# アンインストール: シンボリックリンクを削除
.PHONY: uninstall
uninstall:
	@echo "→ Uninstalling dotfiles..."
	@if [ -L "$(TARGET_CONFIG)" ]; then \
		unlink "$(TARGET_CONFIG)"; \
		echo "  Removed symlink: $(TARGET_CONFIG)"; \
		if [ -e "$(TARGET_CONFIG).backup" ]; then \
			mv "$(TARGET_CONFIG).backup" "$(TARGET_CONFIG)"; \
			echo "  Restored backup: $(TARGET_CONFIG).backup → $(TARGET_CONFIG)"; \
		fi \
	fi
	@if [ -L "$(ZSHENV_TARGET)" ]; then \
		unlink "$(ZSHENV_TARGET)"; \
		echo "  Removed symlink: $(ZSHENV_TARGET)"; \
	fi
	@echo "✔︎ Uninstallation complete."

# クリーン: 不要なファイルを削除
.PHONY: clean
clean: uninstall

# ─────────────────────────────────────────────
