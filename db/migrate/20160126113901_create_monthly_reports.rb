class CreateMonthlyReports < ActiveRecord::Migration
  def change
    create_table :monthly_reports do |t|
      t.float :money_spent
      t.integer :design_days
      t.integer :frontend_days
      t.integer :backend_days
      t.integer :data_days
      t.integer :research_days
      t.date :report_date
      t.references :project, index: true

      t.timestamps null: false
    end
  end
end
