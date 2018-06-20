#!/bin/bash

# Fix Firefox's MIME associations.

sed 's#.*octet-stream.*#application/octet-stream=gnome-open.desktop#' ~/.local/share/applications/mimeapps.list -i
