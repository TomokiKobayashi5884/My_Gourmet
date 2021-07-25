class Contact < ApplicationRecord
    
    validates :subject, presence: true, length: { maximum: 50 }
    validates :message, presence: true, length: { maximum: 350 }
    validates :name, presence: true, length: { maximum: 10 }
    VALID_EMAIL_REGEX = /\A[\w+-.]+@[a-z\d-]+(.[a-z\d-]+)*.[a-z]+\z/i
    validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, length: { maximum: 70 }
    
    extend DisplayList
    
    scope :search_by_keyword, -> (keyword) {
        where("id LIKE ? OR subject LIKE ? OR message LIKE ?", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%") if keyword.present?
    }
    
    scope :search_by_name, -> (name) {
        where(name: name) if name.present?
    }
    
    scope :search_by_email, -> (email) {
        where(email: email) if email.present?
    }
    
end
