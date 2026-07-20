# サイクル 001 — U1 完了

- session: S001
- 日時: 2026-07-20T13:55Z (claim) → 2026-07-20T13:56Z (done)
- unit: U1 ページ骨格の作成

## やったこと

- `build/index.html` を新規作成。HTML5 の骨格(header / main / footer)と
  2 つのプレースホルダ `{{STYLES}}` / `{{CONTENT}}` を配置。
- `checks/verify.sh` で整合性を確認してから done に更新。

## 次のセッションへ

- U2(コンテンツ)と U3(スタイル)が着手可能になった。deps はどちらも U1 のみ。
- プロトコル通り、先に並んでいる U2 から着手すること。
- `{{CONTENT}}` は `<main>` 内のインデント(なし)に合わせて置換してよい。
