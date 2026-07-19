class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.references :profileable, polymorphic: true, index: true
      t.timestamps
    end
    add_index :accounts, :email, unique: true
  end
end
