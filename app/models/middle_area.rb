class MiddleArea < ApplicationRecord
    belongs_to :large_area
    has_many :restaurants
end
