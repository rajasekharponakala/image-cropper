class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_admin, :boolean, :default => false
    add_column :users, :name, :string
  end
end
