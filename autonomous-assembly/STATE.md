# STATE — 自律組み立ての現在状態

このファイルはセッション間で共有される唯一の進捗状態。書式は 1 unit = 1 行で、
`checks/verify.sh` が機械的に検査する。**行の書式を崩さないこと。**

- goal: `build/index.html` として単一ファイルの静的ページを段階的に組み立てる
- done_when: 全 unit が `status:done` かつ `verify.sh` が exit 0
- branch: claude/autonomous-assembly-session-check-ojiq2k

## Units

書式: `- <ID> | <title> | deps:<ID,ID|-> | out:<path> | status:<todo|in_progress|done|failed> | session:<id|-> | claimed_at:<UTC|->`

- U1 | ページ骨格の作成(プレースホルダ入り index.html) | deps:- | out:build/index.html | status:done | session:S001 | claimed_at:2026-07-20T13:55Z
- U2 | コンテンツ節の組み込み({{CONTENT}} を置換) | deps:U1 | out:build/index.html | status:done | session:S002 | claimed_at:2026-07-20T15:11Z
- U3 | スタイルの組み込み({{STYLES}} を置換) | deps:U1 | out:build/index.html | status:todo | session:- | claimed_at:-
- U4 | 最終統合と検証(プレースホルダ残存ゼロ確認・仕上げ) | deps:U2,U3 | out:build/index.html | status:todo | session:- | claimed_at:-

## 直近の状況メモ(人間向け・自由記述)

- S001 が U1 を完了(骨格作成)。次は U2(コンテンツ)から着手すること。詳細は `journal/001-U1-done.md`。
