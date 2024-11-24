class Event < ApplicationRecord
    has_many :tickets, dependent: :destroy
    
    validates :name, presence: true
    validates :event_date, presence: true
    validates :venue, presence: true
    validates :description, presence: true
    validates :ticket_price, presence: true
end