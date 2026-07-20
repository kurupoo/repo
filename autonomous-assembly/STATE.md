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
- U3 | スタイルの組み込み({{STYLES}} を置換) | deps:U1 | out:build/index.html | status:done | session:S002 | claimed_at:2026-07-20T15:12Z
- U4 | 最終統合と検証(プレースホルダ残存ゼロ確認・仕上げ) | deps:U2,U3 | out:build/index.html | status:done | session:S002 | claimed_at:2026-07-20T15:12Z

## 直近の状況メモ(人間向け・自由記述)

- 全 unit(U1〜U4)完了。組み立ては完成し、verify.sh は「組み立て完了」を報告する状態。
- U1 は PR #2 でマージ済み。U2〜U4 はフォローアップとして本ブランチの新 PR で進めた。
- これ以上のサイクルは不要(done_when 達成)。
