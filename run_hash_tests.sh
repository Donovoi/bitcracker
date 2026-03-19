#!/usr/bin/env bash

set -eu

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR="$(mktemp -d /tmp/bitcracker-hash-tests.XXXXXX)"

cleanup() {
	rm -rf "$TMP_DIR"
}

trap cleanup EXIT

mkdir -p "$ROOT_DIR/build"
make -C "$ROOT_DIR/src_HashExtractor" clean
make -C "$ROOT_DIR/src_HashExtractor"
cp "$ROOT_DIR/src_HashExtractor/bitcracker_hash" "$ROOT_DIR/build/bitcracker_hash"

check_image() {
	image_name="$1"
	image_path="$ROOT_DIR/Images/$image_name"
	image_out_dir="$TMP_DIR/$image_name"
	image_log="$TMP_DIR/$image_name.log"
	expected_user_hash="$2"
	expected_recovery_hash="$3"

	mkdir -p "$image_out_dir"
	"$ROOT_DIR/build/bitcracker_hash" -o "$image_out_dir" -i "$image_path" > "$image_log" 2>&1

	grep -q 'Version: 2 (Windows 7 or later, including Windows 11)' "$image_log"
	test "$(cat "$image_out_dir/hash_user_pass.txt")" = "$expected_user_hash"
	test "$(cat "$image_out_dir/hash_recv_pass.txt")" = "$expected_recovery_hash"
}

check_image "imgWin7" \
	'$bitlocker$0$16$89a5bad722db4a729d3c7b9ee8e76a29$1048576$12$304a4ac192a2cf0103000000$60$24de9a6128e8f8ffb97ac72d21de40f63dbc44acf101e68ac0f7e52ecb1be4a8ee30ca1e69fbe98400707ba3977d5f09b14e388c885f312edc5c85c2' \
	'$bitlocker$2$16$8b7be4f7802275ffbdad3766c7f7fa4a$1048576$12$304a4ac192a2cf0106000000$60$6e72f6ef6ba688e72211b8cf8cc722affd308882965dc195f85614846f5eb7d9037d4d63bcc1d6e904f0030cf2e3a95b3e1067447b089b7467f86688'
check_image "imgWin8" \
	'$bitlocker$0$16$0a8b9d0655d3900e9f67280adc27b5d7$1048576$12$b0599ad6c6a1cf0103000000$60$c16658f54140b3d90be6de9e03b1fe90033a2c7df7127bcd16cb013cf778c12072142c484c9c291a496fc0ebd8c21c33b595a9c1587acfc6d8bb9663' \
	'$bitlocker$2$16$cda1b7e0308cffe3d4e3ec9afc7a3e61$1048576$12$b0599ad6c6a1cf0106000000$60$58516d80cb347b7a992e9eb05f8157d79ac2f66d101c796ce6ec40c91706e4d9289bcd7b2790162795a8fdc60696846d7fca26f0f75288fe07536706'
check_image "imgWin10Compat.vhd" \
	'$bitlocker$0$16$9b53194ca3dd1a0f3a7a3f1a744bc67e$1048576$12$a0da3fc75f6cd30103000000$60$da94f514cf552d95f5a684280aa261cb106a240e4f570e0b625cc196b4aec5a03dcb1f766217667934278eb97b91ba6b7b9fc9c0f3701b6270f3fc28' \
	'$bitlocker$2$16$432dd19f37dd413a88552225628c8ae5$1048576$12$a0da3fc75f6cd30106000000$60$3e57c68216ef3d2b8139fdb0ec74254bdf453e688401e89b41cae7c250739a8b36edd4fe86a597b5823cf3e0f41c98f623b528960a4bee00c42131ef'
check_image "imgWin10NotCompat.vhd" \
	'$bitlocker$0$16$a149a1c91be871e9783f51b59fd9db88$1048576$12$b0adb333606cd30103000000$60$c1633c8f7eb721ff42e3c29c3daea6da0189198af15161975f8d00b8933681d93edc7e63f36b917cdb73285f889b9bb37462a40c1f8c7857eddf2f0e' \
	'$bitlocker$2$16$2f8c9fbd1ed2c1f4f034824f418f270b$1048576$12$b0adb333606cd30106000000$60$8323c561e4ef83609aa9aa409ec5af460d784ce3f836e06cec26eed1413667c94a2f6d4f93d860575498aa7ccdc43a964f47077239998feb0303105d'
check_image "imgWin10NotCompatLongPsw.vhd" \
	'$bitlocker$0$16$64054b78d4ba4cff6b20811bae5b6472$1048576$12$304e22c96802d40103000000$60$f2b74b9d6ce5b3bf326a50d6f4117d703e43f86010828a0caa4c370836115aaa1bf9ce5e08a805efc53fe0e4dcc27fbc46f22b23821344c86c240965' \
	'$bitlocker$2$16$775d3b4a49a3cd13914a3839e279cb15$1048576$12$304e22c96802d40106000000$60$de445eaa60675a42608669a7abbbdf05a36ce970c91b256845750c3cc96b684a4fa859592b90764f78bf9dd0c9f48a52f24d2110faa785659a54175a'

printf 'Hash extractor compatibility checks passed.\n'
