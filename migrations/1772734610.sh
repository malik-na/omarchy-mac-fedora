echo "Remap Copilot key to Omarchy Menu using makima"

# makima-bin is not available on all Fedora repo setups.
# Keep migration non-fatal so updates continue cleanly.
if omarchy-pkg-add makima-bin >/dev/null 2>&1; then
	source "$OMARCHY_PATH/install/config/makima.sh"
else
	echo "Skipping makima key remap (makima-bin not available in current repos)"
fi
