class CreateTicketStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :ticket_statuses do |t|
      t.boolean :VIP
      t.boolean :regular
      t.boolean :early_bird

      t.timestamps
    end
  end
end
