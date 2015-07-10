class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :company_name
      t.string :postal_code
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :address4
      t.string :tel

      t.timestamps null: false
    end
  end
end
