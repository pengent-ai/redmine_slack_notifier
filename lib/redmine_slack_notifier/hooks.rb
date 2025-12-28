# frozen_string_literal: true

require_dependency "issue"

module RedmineSlackNotifier
  class Hooks < Redmine::Hook::Listener
    def controller_issues_new_after_save(context = {})
      issue = context[:issue]
      notify(issue, "created", context)
    end

    def controller_issues_edit_after_save(context = {})
      issue = context[:issue]
      notify(issue, "updated", context)
    end

    private

    def notify(issue, action, context = {})
      return if issue.nil?

      setting = RedmineSlackNotifier::ProjectSetting.find_by(project_id: issue.project_id)
      return if setting.nil? || setting.webhook_url.to_s.empty?

      url = Rails.application.routes.url_helpers.issue_url(
        issue,
        host: Setting.host_name,
        protocol: Setting.protocol
      )

      payload = build_payload(issue, action, url, context)
      RedmineSlackNotifier::SlackClient.new.post(setting.webhook_url, payload)
    rescue => e
      Rails.logger.error("[redmine_slack_notifier] notify failed: #{e.class} #{e.message}")
    end

    def build_payload(issue, action, url, context = {})
      title_link = "*<#{url}|##{issue.id} #{escape_slack(issue.subject.to_s)}>*"
      header = "[#{issue.project.name}][#{issue.tracker.name}] Issue #{action}"

      status   = issue.status&.name.to_s
      assignee = issue.assigned_to ? "@#{issue.assigned_to.name}" : "-"
      priority = issue.priority&.name.to_s
      author   = issue.author ? "@#{issue.author.name}" : "-"

      fields = [
        { type: "mrkdwn", text: "*ステータス:* #{escape_slack(status)}" },
        { type: "mrkdwn", text: "*担当者:* #{escape_slack(assignee)}" },
        { type: "mrkdwn", text: "*優先度:* #{escape_slack(priority)}" },
        { type: "mrkdwn", text: "*作成者:* #{escape_slack(author)}" }
      ]

      blocks = []
      blocks << { type: "header", text: { type: "plain_text", text: header, emoji: true } }
      blocks << { type: "section", text: { type: "mrkdwn", text: title_link } }
      blocks << { type: "section", fields: fields }

      if action == "created"
        desc = issue.description.to_s.strip
        unless desc.empty?
          blocks << {
            type: "section",
            text: { type: "mrkdwn", text: "*説明:*\n#{escape_slack(truncate(desc, 1200))}" }
          }
          blocks << { type: "divider" }
        end
      elsif action == "updated"
        comment = extract_notes_from_context(context)
        unless comment.empty?
          blocks << {
            type: "section",
            text: { type: "mrkdwn", text: "*コメント:*\n#{escape_slack(truncate(comment, 1200))}" }
          }
          blocks << { type: "divider" }
        end
      end

      {
        text: "#{header}\n##{issue.id} #{issue.subject}\n#{url}",
        blocks: blocks
      }
    end

    def extract_notes_from_context(context)
      controller = context[:controller]
      controller&.params&.dig(:issue, :notes).to_s.strip
    end

    def escape_slack(text)
      text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    end

    def truncate(text, max_len)
      return text if text.length <= max_len
      text[0, max_len] + "…"
    end
  end
end
