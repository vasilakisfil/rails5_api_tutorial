class AddTokenToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :token, :string

    User.find_each{|user| user.save!}

    change_column_null :users, :token, false
  end

  def down
    remove_column :users, :token, :string
  end
end
