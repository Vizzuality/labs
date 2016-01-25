class AddMoneySpentToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :money_spent, :float
  end
end
