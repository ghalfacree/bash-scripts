#!/bin/bash
# Fix for stupid mDNS resolution breaking in Mac OS X. Stupid thing.
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
echo It may be fixed. Or possibly not. Good luck!
