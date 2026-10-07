# frozen_string_literal: true

require_dependency File.expand_path("app/controllers/slack_notifier_settings_controller", __dir__)

Redmine::Plugin.register :redmine_slack_notifier do
  name "Redmine Slack Notifier plugin"
  author "Ry.yamafuji"
  description "Send Redmine issue events to Slack"
  version "0.1.1"

  project_module :redmine_slack_notifier do
    permission :manage_slack_notifier,
               { slack_notifier_settings: %i[show update] },
               require: :member
  end

  menu :project_menu,
       :slack_notifier,
       { controller: "slack_notifier_settings", action: "show" },
       caption: "Slack Notifier",
       param: :project_id
end
