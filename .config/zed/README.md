# `~/.config/zed`

This is here, since Zed only respects `$XDG_CONFIG_HOME` on Linux. Even if that
was not the case, I point `$XDG_CONFIG_HOME` to `~/Library/Application Support`
on macOS, which already contains a `Zed` directory (and APFS is case-insensitive
by default).

`settings.json` is NOT synced automatically, since it can contain information
like remote hosts or MCP API keys. It's updated when I remember to.
