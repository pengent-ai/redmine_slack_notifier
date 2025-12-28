# redmine_slack_notifier

RedmineからSlack通知のためのプラグイン


* 新しい`Incoming Webhooks`の対応しました
* `chat.postMessage`については対応予定です


## インストール方法

```sh
cd /opt/redmine/plugins
git clone https://github.com/pengent-ai/redmine_slack_notifier.git
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

