class Restaurant < ApplicationRecord
    belongs_to :middle_area
    belongs_to :large_area
    has_many :posts, dependent: :destroy
    
    validates :large_area_id, presence: true
    validates :middle_area_id, presence: true
    validates :name, length: { maximum: 50 }
    validates :address, length: { maximum: 100 }
    validates :open_time, length: { maximum: 250 }
    validates :close_day, length: { maximum: 250 }
    
    attr_accessor :large_area_code
    attr_accessor :middle_area_code
    
    
end
