class CreateRedmineSlackNotifierProjectSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :redmine_slack_notifier_project_settings do |t|
      t.integer :project_id, null: false
      t.text :webhook_url, null: false
      t.timestamps
    end

    add_index :redmine_slack_notifier_project_settings, :project_id, unique: true
  end
end
