# Release / Deploy

## 概要

このプラグインは Redmine のプラグインとして動作するため、修正内容は Redmine の Docker 環境に反映してから、必要に応じて migration と再起動を行う。

1. 開発中の修正は`develop`ブランチで行い、リリース時に Redmine 環境へ反映する。
2. `develop`ブランチから`main`ブランチにマージする。
3. `main`ブランチから`releases`ブランチにマージする(github)
4. バージョンのタグ付けを行います


