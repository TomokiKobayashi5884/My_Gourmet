class MiddleArea < ApplicationRecord
    belongs_to :large_area
    has_many :restaurants
    
    validates :name, presence: true, uniqueness: true
    validates :middle_area_code, presence: true, uniqueness: true
    validates :large_area_id, presence: { message: "を選択してください" }
    
    extend DisplayList
    
    scope :search_by_keyword, -> (keyword) {
        where("id LIKE ? OR name LIKE ? OR middle_area_code LIKE ?", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%") if keyword.present?
    }
    
    scope :search_by_large_area, -> (large_area_id) {
        where(large_area_id: large_area_id) if large_area_id.present?
    }
end
