#!/usr/bin/env bash
#
# Prompt Intercept Pattern — UserPromptSubmit hook
#
# Intercepts /prompt-intercept-pattern, runs code, and blocks the API call.
# The stub command file exists only for /help discoverability.
#
# Input:  JSON on stdin (from Claude Code)
# Output: JSON on stdout (decision + reason shown to user)
#
# Requires: jq

set -euo pipefail

input="$(cat)"
prompt="$(echo "$input" | jq -r '.prompt // .user_prompt // ""')"

# Only handle our command — pass everything else through
case "$prompt" in
  /prompt-intercept-pattern*)
    ;;
  *)
    echo '{}'
    exit 0
    ;;
esac

# Strip the command name to get arguments
args="${prompt#/prompt-intercept-pattern}"
args="${args# }"  # trim leading space

if [ -z "$args" ]; then
  message="No arguments provided. Usage: /prompt-intercept-pattern [message]"
else
  message="Echoed: $args"
fi

# Block the prompt (no API call) and show the message to the user
jq -n --arg reason "$message" '{
  decision: "block",
  reason: $reason
}'
