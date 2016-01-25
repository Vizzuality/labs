class AddEstimatesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :design_days, :integer
    add_column :projects, :backend_days, :integer
    add_column :projects, :frontend_days, :integer
    add_column :projects, :mgmt_days, :integer
    add_column :projects, :data_days, :integer
    add_column :projects, :research_days, :integer
  end
end
