class AddFieldsToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :event_date, :datetime
    add_column :events, :venue, :string
    add_column :events, :description, :text
    add_column :events, :ticket_price, :decimal
    add_column :events, :available_tickets, :integer
  end
end
