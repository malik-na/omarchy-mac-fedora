#!/bin/bash

if pgrep -f "\b(wf-recorder|gpu-screen-recorder)\b" >/dev/null; then
  echo '{"text": "󰻂", "tooltip": "Stop recording", "class": "active", "alt": "active"}'
else
  echo '{"text": "", "tooltip": "", "class": "inactive", "alt": "inactive"}'
fi
