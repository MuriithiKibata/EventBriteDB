class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :quantity
      t.integer :price
      t.string :ticket_type
      t.string :payment_type
      t.string :phone_number
      t.boolean :payment_status, :default => false
      t.timestamps
    end
  end
end
