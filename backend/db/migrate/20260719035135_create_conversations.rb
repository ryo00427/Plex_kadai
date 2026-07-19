class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.references :company, null: false, foreign_key: true
      t.references :intern, null: false, foreign_key: true
      t.timestamps
    end
    add_index :conversations, %i[company_id intern_id], unique: true
  end
end
