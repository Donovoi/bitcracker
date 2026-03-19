#!/usr/bin/env bash

set -eu

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR="$(mktemp -d /tmp/bitcracker-hash-tests.XXXXXX)"

cleanup() {
	rm -rf "$TMP_DIR"
}

trap cleanup EXIT

mkdir -p "$ROOT_DIR/build"
gcc "$ROOT_DIR/src_HashExtractor/bitcracker_hash.c" -o "$ROOT_DIR/build/bitcracker_hash"

check_image() {
	image_name="$1"
	image_path="$ROOT_DIR/Images/$image_name"
	image_out_dir="$TMP_DIR/$image_name"
	image_log="$TMP_DIR/$image_name.log"

	mkdir -p "$image_out_dir"
	"$ROOT_DIR/build/bitcracker_hash" -o "$image_out_dir" -i "$image_path" > "$image_log" 2>&1

	grep -q 'Version: 2 (Windows 7 or later, including Windows 11)' "$image_log"
	test -s "$image_out_dir/hash_user_pass.txt"
	test -s "$image_out_dir/hash_recv_pass.txt"
}

check_image "imgWin7"
check_image "imgWin8"
check_image "imgWin10Compat.vhd"
check_image "imgWin10NotCompat.vhd"
check_image "imgWin10NotCompatLongPsw.vhd"

printf 'Hash extractor compatibility checks passed.\n'
