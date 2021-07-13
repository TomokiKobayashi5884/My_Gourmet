require 'net/http'
require 'json'

keyid = ENV["KEYID"]
data_format = "json"
prepare_params = { "key": keyid, "format": data_format }

# ホットペッパーから中エリア名を取得
def prepare_search(prepare_params)
      @middle_areas = []
      
      uri = URI.parse("http://webservice.recruit.co.jp/hotpepper/middle_area/v1/")
      uri.query = URI.encode_www_form(prepare_params)  
  
      json_res = Net::HTTP.get uri
      
      # JSON.load(response)
      response = JSON.load(json_res)
      
      if response.has_key?("error") then
          puts "エラーが発生しました！"
      end
      
      response["results"]["middle_area"].each do |middle_area|
          middle_areas_info = [ middle_area["name"], middle_area["code"], middle_area["large_area"]["code"] ]
          @middle_areas.append(middle_areas_info)
      end
     
      return @middle_areas
end
    
    
prepare_search(prepare_params)

MiddleArea.all.destroy_all
    
# 中エリア名を大エリアの情報と結びつけてシードデータとして保存
@middle_areas.each_with_index do |middle_area, i|
    
    large_area = LargeArea.find_by(large_area_code: middle_area[2])
    
    MiddleArea.create(
                id: i+1,
                name: middle_area[0],
                middle_area_code: middle_area[1],
                large_area_id: large_area.id
                    )
    
end
