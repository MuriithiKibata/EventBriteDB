class Ticket < ApplicationRecord
    belongs_to :event

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :phone_number, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
end
