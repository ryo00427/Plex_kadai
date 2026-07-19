class CreateCompanies < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :industry
      t.text :description
      t.string :website
      t.timestamps
    end
  end
end
