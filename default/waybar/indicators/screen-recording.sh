#!/bin/bash

if pgrep -x wf-recorder >/dev/null 2>&1 || pgrep -f '(^|[[:space:]/])gpu-screen-recorder([[:space:]]|$)' >/dev/null 2>&1; then
  echo '{"text":"󰻂","tooltip":"Stop recording","class":"active","alt":"active"}'
else
  echo '{"text":"","tooltip":"","class":"inactive","alt":"inactive"}'
fi
