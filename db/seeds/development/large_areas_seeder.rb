require 'net/http'
require 'json'

keyid = ENV["KEYID"]
data_format = "json"
prepare_params = { "key": keyid, "format": data_format }

# ホットペッパーから大エリア名、大エリアコードを取得
  def prepare_search(prepare_params)
      @large_areas = []
      
      uri = URI.parse("http://webservice.recruit.co.jp/hotpepper/large_area/v1/")
      uri.query = URI.encode_www_form(prepare_params)  
  
      json_res = Net::HTTP.get uri
      
      response = JSON.load(json_res)
      
      if response.has_key?("error") then
          puts "エラーが発生しました！"
      end
      
      response["results"]["large_area"].each do |large_area|
          large_areas_info = [large_area["code"],large_area["name"]]
          @large_areas.append(large_areas_info)
      end
    
      return @large_areas
    end
    
    prepare_search(prepare_params)
    
    LargeArea.all.destroy_all
    
    # 大エリア名、大エリアコードをシードデータとして保存
    @large_areas.each_with_index do |large_area_array, i|
        LargeArea.create(
            id: i + 1,
            large_area_code: large_area_array[0],
            name: large_area_array[1]
            )
    end