#!/bin/bash

# Script to fix orphaned print statements in Flutter project

LIB_DIR="c:\Users\DELL\Downloads\venta_cuba111\venta_cuba\lib"

# Fix patterns - find lines starting with whitespace + quote and ending with ");
# and add print( at the beginning

# Find and fix all orphaned strings in location_controller.dart
echo "Fixing location_controller.dart..."

# Use sed to fix the patterns
sed -i 's/^\(\s*\)"\(.*\)");$/\1print("\2");/g' "$LIB_DIR/Controllers/location_controller.dart"
sed -i "s/^\(\s*\)'\(.*\)');$/\1print('\2');/g" "$LIB_DIR/Controllers/location_controller.dart"

echo "Done with location_controller.dart"