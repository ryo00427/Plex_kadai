class CreateJobPostings < ActiveRecord::Migration[7.2]
  def change
    create_table :job_postings do |t|
      t.references :company, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.text :requirements
      t.string :location
      t.string :employment_type
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
