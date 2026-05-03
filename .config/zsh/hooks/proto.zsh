# .config/zsh/hooks/proto.zsh

_lazy_proto_activate() {
  if [[ -f ".prototools" ]] && command -v proto >/dev/null 2>&1; then
    eval "$(proto activate zsh)"
    add-zsh-hook -d chpwd _lazy_proto_activate
  fi
}

