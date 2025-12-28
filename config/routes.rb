# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  get  "projects/:project_id/slack_notifier", to: "slack_notifier_settings#show"
  post "projects/:project_id/slack_notifier", to: "slack_notifier_settings#update"
end