json.meta do
  json.total_pages @hot_restaurants.total_pages
  json.current_page @hot_restaurants.current_page
  json.total_count @hot_restaurants.total_count
  json.limit_value @hot_restaurants.limit_value
end
json.data do
  json.array! @hot_restaurants do |hot_restaurant|
    json.id hot_restaurant.id
    json.photo hot_restaurant.photo
    json.name hot_restaurant.name
    json.genre hot_restaurant.genre
    json.address hot_restaurant.address
    json.open hot_restaurant.open
    json.close hot_restaurant.close
    json.urls hot_restaurant.urls
    json.large_area hot_restaurant.large_area
    json.middle_area hot_restaurant.middle_area
  end
end