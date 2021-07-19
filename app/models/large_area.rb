class LargeArea < ApplicationRecord
    has_many :middle_areas
    has_many :restaurants
    
    validates :name, presence: true, uniqueness: true
    validates :large_area_code, presence: true, uniqueness: true
    
    extend DisplayList
    
    scope :search_by_keyword, -> (keyword) {
        where("id LIKE ? OR name LIKE ? OR large_area_code LIKE ?", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
    }
    
    # scope :search_name, -> (name) {
    #     where("name LIKE ?", "%#{name}%")
    # }
end
