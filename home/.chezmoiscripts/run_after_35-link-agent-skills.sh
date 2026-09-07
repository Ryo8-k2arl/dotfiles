#!/bin/sh

set -eu

# One skill definition, every agent. Claude Code, Codex, and Gemini CLI all
# discover user skills as <agent home>/skills/<name>/SKILL.md, and all three
# follow symbolic links, so the canonical copy lives in ~/.config/agent-skills
# and each agent receives a link into it.
#
# The links are created per skill rather than by replacing the whole skills
# directory: Codex keeps its built-in skills in ~/.codex/skills/.system, which
# a directory-level link would hide.

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
skills_dir="$config_home/agent-skills"

mkdir -p "$skills_dir"

for agent_home in "$HOME/.claude" "$HOME/.codex" "$HOME/.gemini"; do
  # Never create an agent home on a host where that agent is not installed.
  [ -d "$agent_home" ] || continue

  agent_skills="$agent_home/skills"
  mkdir -p "$agent_skills"

  # Drop links to skills this repository no longer deploys. Only links into
  # the canonical directory are considered, so skills the agent installed for
  # itself are left untouched.
  for link in "$agent_skills"/*; do
    [ -L "$link" ] || continue
    case "$(readlink "$link")" in
      "$skills_dir"/*)
        [ -d "$link" ] || rm -f "$link"
        ;;
    esac
  done

  for skill in "$skills_dir"/*/; do
    [ -f "$skill/SKILL.md" ] || continue

    link="$agent_skills/$(basename "$skill")"
    if [ -e "$link" ] && [ ! -L "$link" ]; then
      printf '%s\n' \
        "Skipping $link: it exists and is not a link into $skills_dir" >&2
      continue
    fi

    ln -sfn "${skill%/}" "$link"
  done
done
