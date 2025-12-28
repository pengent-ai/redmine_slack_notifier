# frozen_string_literal: true

require_dependency "issue"

# Hook チケットの作成/更新/削除時に Slack へ通知を送信する
module RedmineSlackNotifier
  class Hooks < Redmine::Hook::Listener

    def controller_issues_new_after_save(context = {})
      issue = context[:issue]
      notify(issue, "created")
    end

    def controller_issues_edit_after_save(context = {})
      issue = context[:issue]
      notify(issue, "updated")
    end

    def controller_issues_destroy_after_destroy(context = {})
      issue = context[:issue]
      notify(issue, "deleted")
    end

    private

    def notify(issue, action)
      return if issue.nil?

      setting = RedmineSlackNotifier::ProjectSetting.find_by(project_id: issue.project_id)
      return if setting.nil? || setting.webhook_url.to_s.empty?

      url = Rails.application.routes.url_helpers.issue_url(issue, host: Setting.host_name, protocol: Setting.protocol)

      payload = {
        text: "[#{issue.project.name}] Issue #{action}: ##{issue.id} #{issue.subject}\n#{url}"
      }


      RedmineSlackNotifier::SlackClient.new.post(setting.webhook_url, payload)
    rescue => e
      Rails.logger.error("[redmine_slack_notifier] notify failed: #{e.class} #{e.message}")
    end
  end
end      

