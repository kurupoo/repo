# セッション起動トリガーの選択肢

このプロトコルは「どうやって次のセッションを起こすか」に依存しない。
以下のいずれでも駆動できる(併用も可)。

## 1. send_later による自己チェックイン(現在使用中)

Claude Code リモートセッションが、自分自身に「約 60 分後にチェックイン」を
予約してからターンを終える方式。チェックインが届いたら PROTOCOL.md の
サイクルを 1 回実行し、未完了なら次のチェックインを再予約する。

- 長所: 追加設定不要。完了したら予約をやめるだけで自然に停止する。
- 短所: 同一セッションの再開なのでコンテキストが引き継がれる
  (= 「リポジトリだけから復元できるか」のテストとしては弱い)。

## 2. Routine(cron)で毎回新規セッションを起動

`create_trigger` で `create_new_session_on_fire: true` の Routine を作ると、
毎回まっさらなセッションが立ち上がる。各セッションはリポジトリの
STATE.md だけを頼りに続きを組み立てる — プロトコルの純粋なテストになる。

- 長所: 真の「セッション間」自律動作。コンテキスト汚染がない。
- 短所: 毎回リポジトリの clone とプロトコル読解から始まるためコスト高。
- 停止: 全 unit done を検知したセッションが Routine を削除する。

## 3. GitHub Actions の cron + claude-code-action

リポジトリ側の workflow で定期起動する構成(参考例。ワークフローの追加には
リポジトリ側の設定と API キーの Secrets 登録が必要):

```yaml
name: autonomous-assembly
on:
  schedule:
    - cron: "0 * * * *"   # 毎時
jobs:
  cycle:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: claude/autonomous-assembly-session-check-ojiq2k
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            autonomous-assembly/PROTOCOL.md を読み、サイクルを 1 回だけ実行して
            コミット・プッシュしてください。全 unit が done なら何もせず終了。
```

## イベント駆動の補助

- PR への購読 (`subscribe_pr_activity`) により、CI 失敗やレビューコメントが
  届いた時点でもセッションが起き、修復サイクルを回せる。
- 人間は PR に「stop」とコメントすることでいつでも停止させられる。
