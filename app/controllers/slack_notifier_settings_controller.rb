# frozen_string_literal: true

class SlackNotifierSettingsController < ApplicationController
  before_action :find_project_by_project_id
  before_action :authorize

  def show
    @setting = RedmineSlackNotifier::ProjectSetting.find_or_initialize_by(project_id: @project.id)
  end

  def update
    @setting = RedmineSlackNotifier::ProjectSetting.find_or_initialize_by(project_id: @project.id)
    @setting.webhook_url = params.dig(:slack_notifier, :webhook_url).to_s.strip

    if @setting.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to "/projects/#{@project.identifier}/slack_notifier"
    else
      render :show
    end
  end
end
