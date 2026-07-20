#!/usr/bin/env bash
# 自律組み立ての整合性検証。
# STATE.md と build/ 成果物の矛盾を検出する。exit 0 = 整合、exit 1 = 不整合。
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE="$ROOT/STATE.md"
ERRORS=0

fail() { echo "NG: $1"; ERRORS=$((ERRORS + 1)); }
ok()   { echo "ok: $1"; }

[ -f "$STATE" ] || { echo "NG: STATE.md がない"; exit 1; }

# unit 行の抽出(書式: - ID | title | deps:.. | out:.. | status:.. | session:.. | claimed_at:..)
UNIT_LINES="$(grep -E '^- U[0-9]+ \|' "$STATE")"
[ -n "$UNIT_LINES" ] || { echo "NG: unit 行が 1 つも見つからない"; exit 1; }

# 1. 各行の書式と status 値の検査
while IFS= read -r line; do
  id="$(echo "$line" | awk '{print $2}')"
  status="$(echo "$line" | grep -oE 'status:[a-z_]+' | cut -d: -f2)"
  case "$status" in
    todo|in_progress|done|failed) ok "$id status=$status" ;;
    *) fail "$id の status が不正: '$status'" ;;
  esac
done <<< "$UNIT_LINES"

# 2. in_progress は同時に 1 つまで
IN_PROGRESS_COUNT="$(echo "$UNIT_LINES" | grep -c 'status:in_progress')"
if [ "$IN_PROGRESS_COUNT" -gt 1 ]; then
  fail "in_progress の unit が ${IN_PROGRESS_COUNT} 個ある(最大 1)"
else
  ok "in_progress は ${IN_PROGRESS_COUNT} 個"
fi

# 3. done / in_progress の unit の依存はすべて done であること
while IFS= read -r line; do
  id="$(echo "$line" | awk '{print $2}')"
  status="$(echo "$line" | grep -oE 'status:[a-z_]+' | cut -d: -f2)"
  deps="$(echo "$line" | grep -oE 'deps:[^ ]+' | cut -d: -f2)"
  [ "$status" = "done" ] || [ "$status" = "in_progress" ] || continue
  [ "$deps" = "-" ] && continue
  for dep in $(echo "$deps" | tr ',' ' '); do
    dep_status="$(echo "$UNIT_LINES" | grep -E "^- $dep \|" | grep -oE 'status:[a-z_]+' | cut -d: -f2)"
    if [ "$dep_status" != "done" ]; then
      fail "$id は $dep に依存するが $dep は '$dep_status'"
    fi
  done
done <<< "$UNIT_LINES"

# 4. done の unit の成果物 (out:) が実在すること
while IFS= read -r line; do
  id="$(echo "$line" | awk '{print $2}')"
  status="$(echo "$line" | grep -oE 'status:[a-z_]+' | cut -d: -f2)"
  out="$(echo "$line" | grep -oE 'out:[^ ]+' | cut -d: -f2)"
  [ "$status" = "done" ] || continue
  if [ -f "$ROOT/$out" ]; then
    ok "$id の成果物 $out が存在"
  else
    fail "$id は done だが成果物 $ROOT/$out がない"
  fi
done <<< "$UNIT_LINES"

# 5. 全 unit done なら、成果物にプレースホルダ {{...}} が残っていないこと
TOTAL="$(echo "$UNIT_LINES" | wc -l)"
DONE="$(echo "$UNIT_LINES" | grep -c 'status:done')"
if [ "$DONE" -eq "$TOTAL" ]; then
  if grep -rE '\{\{[A-Z_]+\}\}' "$ROOT/build/" >/dev/null 2>&1; then
    fail "全 unit done なのにプレースホルダが残っている:"
    grep -rnE '\{\{[A-Z_]+\}\}' "$ROOT/build/"
  else
    ok "全 unit done、プレースホルダ残存なし — 組み立て完了"
  fi
else
  ok "進捗: ${DONE}/${TOTAL} unit 完了"
fi

if [ "$ERRORS" -gt 0 ]; then
  echo "== 検証失敗: ${ERRORS} 件の不整合 =="
  exit 1
fi
echo "== 検証 OK =="
exit 0
