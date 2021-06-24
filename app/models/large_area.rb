class LargeArea < ApplicationRecord
    has_many :middle_areas
    has_many :restaurants
end
