class Contact < ApplicationRecord
    
    validates :subject, presence: true, length: { maximum: 50 }
    validates :message, presence: true, length: { maximum: 350 }
    validates :name, presence: true, length: { maximum: 10 }
    VALID_EMAIL_REGEX = /\A[\w+-.]+@[a-z\d-]+(.[a-z\d-]+)*.[a-z]+\z/i
    validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, length: { maximum: 70 }
    
end
