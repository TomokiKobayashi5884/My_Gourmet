json.meta do
  json.total_pages @hot_restaurants.total_pages
  json.current_page @hot_restaurants.current_page
  json.total_count @hot_restaurants.total_count
  json.limit_value @hot_restaurants.limit_value
end
json.data do
  json.array! @h_restaurant
end