#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="wordpress-security-rescue"
RAW_URL="https://raw.githubusercontent.com/ilovefiniki/wordpress-security-rescue/main/SKILL.md"

echo "Installing ${SKILL_NAME} across AI agent skill directories..."

for dir in ".claude/skills/${SKILL_NAME}" ".agents/skills/${SKILL_NAME}"; do
  mkdir -p "${dir}"
  curl -fsSL "${RAW_URL}" -o "${dir}/SKILL.md"
  echo "  ✓ Installed -> ${dir}/SKILL.md"
done

echo "Done! Trigger the skill in your agent by mentioning '${SKILL_NAME}'."
