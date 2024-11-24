class AddEventIdToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :event_id, :integer
  end
end
