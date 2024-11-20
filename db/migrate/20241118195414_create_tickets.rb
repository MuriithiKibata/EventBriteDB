class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.string :first_name
      t.string :last_name
      t.boolean :paid
      t.integer :event_id
      t.integer :price
      t.timestamps
    end
  end
end
