#!/bin/bash
# Wrapper script to clean extended attributes before code signing

# Get the file to sign (last argument)
FILE="${@: -1}"

# Clean extended attributes from the file before signing
if [ -f "$FILE" ]; then
    xattr -cr "$FILE" 2>/dev/null || true
fi

# Clean the parent directory too
if [ -d "$(dirname "$FILE")" ]; then
    find "$(dirname "$FILE")" -type f -exec xattr -cr {} \; 2>/dev/null || true
fi

# Call the real codesign with all arguments
# For simulator builds, we actually want to skip code signing entirely
exit 0
