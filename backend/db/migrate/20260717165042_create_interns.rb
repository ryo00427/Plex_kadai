class CreateInterns < ActiveRecord::Migration[7.2]
  def change
    create_table :interns do |t|
      t.string :name, null: false
      t.string :university
      t.string :major
      t.integer :graduation_year
      t.string :skills
      t.text :bio
      t.timestamps
    end
  end
end
