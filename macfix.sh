#!/bin/bash
# Fix for stupid mDNS resolution breaking in Mac OS X. Stupid thing.
launchctl unload -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
launchctl load -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
echo It may be fixed. Or possibly not. Good luck!
