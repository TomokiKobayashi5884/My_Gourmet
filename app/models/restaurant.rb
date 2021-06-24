class Restaurant < ApplicationRecord
    belongs_to :middle_area
    belongs_to :large_area
    has_many :posts, dependent: :destroy
    
    attr_accessor :large_area_code
    attr_accessor :middle_area_code
    
end
