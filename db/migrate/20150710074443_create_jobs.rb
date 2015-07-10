class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.references :company, index: true, foreign_key: true
      t.string :job_name
      t.text :work_address
      t.string :category
      t.string :job_type
      t.text :job_info
      t.text :requirement
      t.string :work_time
      t.text :salary
      t.string :holiday
      t.text :treatment
      t.string :capture_url
      t.string :site
      t.datetime :update_time
      t.datetime :register_time

      t.timestamps null: false
    end
  end
end
