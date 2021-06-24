require 'net/http'
require 'json'

keyid = ENV["KEYID"]
data_format = "json"
prepare_params = { "key": keyid, "format": data_format }

# ホットペッパーからジャンル名,ジャンルコードを取得
def seed_prepare(prepare_params)
       @genres = []
      
      uri = URI.parse("http://webservice.recruit.co.jp/hotpepper/genre/v1/")
      uri.query = URI.encode_www_form(prepare_params)  
  
      json_res = Net::HTTP.get uri
      
      response = JSON.load(json_res)
      
      if response.has_key?("error") then
          puts "エラーが発生しました！"
      end
      
      response["results"]["genre"].each do |genre|
          genres_info = [genre["name"], genre["code"]]
          @genres.append(genres_info)
      end
      
      return @genres
end
    
seed_prepare(prepare_params)

Genre.all.destroy_all
# ジャンル名、ジャンルコードをシードデータとして保存
@genres.each_with_index do |genre_array, i|
    Genre.create(
        id: i + 1,
        name: genre_array[0],
        genre_code: genre_array[1]
        )
end

