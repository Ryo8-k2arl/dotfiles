# dotfiles のルートディレクトリ
DOTFILES_DIR := $(shell pwd)
CONFIG_DIR := $(DOTFILES_DIR)/.config
TARGET_CONFIG_DIR := $(HOME)/.config
ZSHENV_SOURCE := $(DOTFILES_DIR)/.zshenv
ZSHENV_TARGET := $(HOME)/.zshenv

# デフォルトターゲット
.PHONY: all
all: install

# インストール: シンボリックリンクを作成
.PHONY: install
install:
	@echo "Installing dotfiles..."
	@mkdir -p $(TARGET_CONFIG_DIR)
	@cd $(CONFIG_DIR) && find . -type f | while read file; do \
		mkdir -p $(TARGET_CONFIG_DIR)/$$(dirname $$file); \
		ln -sf $(CONFIG_DIR)/$$file $(TARGET_CONFIG_DIR)/$$file; \
	done
	@ln -sf $(ZSHENV_SOURCE) $(ZSHENV_TARGET)
	@echo "Installation complete."
	@echo "Please restart your shell to apply changes."

# アンインストール: シンボリックリンクを削除
.PHONY: uninstall
uninstall:
	@echo "Uninstalling dotfiles..."
	@cd $(CONFIG_DIR) && find . -type f | while read file; do \
		TARGET="$(TARGET_CONFIG_DIR)/$$file"; \
		if [ -L "$$TARGET" ]; then \
			rm "$$TARGET"; \
			echo "Removed symlink: $$TARGET"; \
		else \
			echo "Skipped (not a symlink): $$TARGET"; \
		fi \
	done
	@if [ -L "$(ZSHENV_TARGET)" ]; then \
		rm "$(ZSHENV_TARGET)"; \
		echo "Removed symlink: $(ZSHENV_TARGET)"; \
	else \
		echo "Skipped (not a symlink): $(ZSHENV_TARGET)"; \
	fi
	@echo "Uninstallation complete."

# クリーン: 不要なファイルを削除
.PHONY: clean
clean: uninstall
