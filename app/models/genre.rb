class Genre < ApplicationRecord
    has_many :post
    
    validates :name, presence: true, uniqueness: true
    validates :genre_code, presence: true, uniqueness: true
    
    extend DisplayList
    
    scope :search_by_keyword, -> (keyword) {
        where("id LIKE ? OR name LIKE ? OR genre_code LIKE ?", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%") if keyword.present?
    }
end
