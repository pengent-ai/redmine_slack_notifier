# frozen_string_literal: true

module RedmineSlackNotifier
  class ProjectSetting < ActiveRecord::Base
    self.table_name = "redmine_slack_notifier_project_settings"

    belongs_to :project

    validates :project_id, presence: true, uniqueness: true
    validates :webhook_url,
              presence: true,
              format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  end
end
