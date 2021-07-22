class Dashboard::RestaurantsController < ApplicationController
    before_action :authenticate_admin!, except: :index
    before_action :set_restaurant, only: %w[show edit update destroy]
    layout "dashboard/dashboard"
    
    HOTPEPPER_PER = 10
    def index
        # 店舗情報検索機能
        restaurants = Restaurant.search_by_keyword(params[:keyword])
        @restaurants = restaurants.display_list(params[:page])
        @total_count = restaurants.count
    end
    
    def show
    end
    
    def new
        @large_areas = LargeArea.all
        @middle_areas = MiddleArea.all
        @genres = Genre.all
        @restaurant = Restaurant.new
        
        # --------------------------------ホットペッパーでの-店舗検索処理----------------------------------------
        # ホットペッパーで検索の際の検索条件から検索用にパラメータを加工
        if params[:keyword] != nil
          keyword = params[:keyword].strip
        else
          keyword = ""
        end
        
        if params[:large_area_selected].present?
          large_area = params[:large_area_selected]
          
          if params[:restaurant][:middle_area_code].present?
            middle_area = params[:restaurant][:middle_area_code]
          else
            middle_area = ""
          end
        else
          large_area = ""
        end
        
        if params[:genre_selected].present?
          genre = params[:genre_selected]
        else
          genre = ""
        end
        # 検索結果の何件目から出力するか
        if params[:start].present?
          start = params[:start]
        else
          start = 1
        end
        # 検索用パラメータ
        keyid = ENV["KEYID"]
        data_format = "json"
        search_params = { "key": keyid, "keyword": keyword, "large_area": large_area, "middle_area": middle_area, "genre": genre, "format": data_format, "start": start }
        
        # 入力された条件を元にホットペッパーで店舗を検索
        search(search_params)
        
        # -----------------------------------------ホットペッパー検索部分のページネーション-------------------------------
        # 最大ページ数
        @max_page = ( @available_restaurants.to_f / HOTPEPPER_PER ).ceil
        
        if params[:page] === "≪"
          @current_page = 1
        elsif params[:page] === "≫"
          @current_page = @max_page
        else
          @current_page = ( params[:start].to_i + ( HOTPEPPER_PER - 1 ) ) / HOTPEPPER_PER
        end
        
        @pagination = {}
        # 検索条件にマッチする店舗がある場合のみページネーションを表示
        if @available_restaurants != nil && @available_restaurants != 0
          @pagination["≪"] = 1 if @current_page >= 4
          @pagination["<"] = @current_page - 1 if @current_page != 1
          
          # 現在のページが真ん中に来るようにする
          if @current_page >= @max_page - 2
            logger.debug('-------------------current_pageがmax_page - 4より大きい場合')
            @pagination.merge!( { @max_page - 4 => @max_page - 4, @max_page - 3 => @max_page - 3, @max_page - 2 => @max_page - 2, @max_page - 1 => @max_page - 1, @max_page => @max_page } )
            # 最大ページ数が5ページ未満の場合に、マイナスのページが出ないようにする
            delete_list = [ 0, -1, -2, -3 ]
            @pagination.delete_if do |page, start|
              delete_list.include?(start)
            end
          elsif @current_page == 1
             @pagination.merge!( { @current_page => @current_page, @current_page + 1 => @current_page + 1, @current_page + 2 => @current_page + 2, @current_page + 3 => @current_page + 3, @current_page + 4 => @current_page + 4 } )
          elsif @current_page == 2
             @pagination.merge!( { @current_page - 1 => @current_page - 1, @current_page => @current_page, @current_page + 1 => @current_page + 1, @current_page + 2 => @current_page + 2, @current_page + 3 => @current_page + 3 } )
          else
            logger.debug('-------------------current_pageがmax_page - 4より小さい場合')
            @pagination.merge!( { @current_page - 2 => @current_page - 2, @current_page - 1 => @current_page - 1, @current_page => @current_page, @current_page + 1 => @current_page + 1, @current_page + 2 => @current_page + 2 } )
          end
          
          @pagination[">"] = @current_page + 1 if @current_page != @max_page
          @pagination["≫"] = @max_page if @current_page <= @max_page - 3
        end
        
        # ホットペッパーの店舗情報をフォームに自動入力する際ののパラメータを加工
        processing_restaurant_params( params[:name], params[:address], params[:open_time], params[:close_day], params[:hotpepper_id], params[:url] )
        
        if params[:large_area_code].present?
          @large_area_id = LargeArea.where(large_area_code: params[:large_area_code]).pluck(:id)[0]
          
        else
          @large_area_id = nil
        end
          
        if params[:middle_area_code].present?
          @middle_area_id = MiddleArea.where(middle_area_code: params[:middle_area_code]).pluck(:id)[0]
        else
          @middle_area_id = nil
        end
    end
    
    def create
        @restaurant = Restaurant.new(restaurant_params)
       if @restaurant.save
           flash[:notice] = "#{@restaurant.name}を新規作成しました"
           redirect_to dashboard_restaurants_path
       else
           flash.now[:alert] = "新規作成に失敗しました"
           @large_areas = LargeArea.all
           @middle_areas = MiddleArea.all
           @genres = Genre.all
           render :new
       end
    end
    
    def edit
        @large_areas = LargeArea.all
        @middle_areas = MiddleArea.all
        @genres = Genre.all
        @large_area_id = @restaurant.large_area_id
        @middle_area_id = @restaurant.middle_area_id
    end
    
    def update
      if @restaurant.update(restaurant_params)
        flash[:notice] = "#{@restaurant.name}を編集しました"
        redirect_to dashboard_restaurants_path
      else
        flash[:alert] = "#{@restaurant.name}の編集に失敗しました"
        @large_areas = LargeArea.all
        @middle_areas = MiddleArea.all
        @genres = Genre.all
        @large_area_id = @restaurant.large_area_id
        @middle_area_id = @restaurant.middle_area_id
        render :edit
      end
    end
    
    def destroy
      if @restaurant.destroy
        flash[:notice] = "#{@restaurant.name}を削除しました"
      else
        flash[:alert] = "#{@restaurant.name}の削除に失敗しました"
      end
      redirect_to dashboard_restaurants_path
    end
    
    
    private
        
        def set_restaurant
            @restaurant = Restaurant.find(params[:id])
        end
        
        def restaurant_params
            params.require(:restaurant).permit(:name, :address, :open_time, :close_day, :large_area_id, :middle_area_id, :url, :hotpepper_id)
        end
        
        # ホットペッパーで店舗を検索し、ハッシュに格納する処理
        def search(search_params)
          @h_restaurants = Hash.new { |h,k| h[k] = {} }
          uri = URI.parse("http://webservice.recruit.co.jp/hotpepper/gourmet/v1/")
          uri.query = URI.encode_www_form(search_params)  
      
          json_res = Net::HTTP.get uri
          
          response = JSON.load(json_res)
          
          if response["results"].has_key?("error")
            puts "エラーが発生しました！"
            @h_restaurants = {}
          else
            # 検索条件にマッチする全件数
            @available_restaurants = response["results"]["results_available"]
            logger.debug("-------------------@available_restaurants #{@available_restaurants}")
            # 検索結果にマッチしたレストランの情報
            response["results"]["shop"].each do |h_restaurant|
            @h_restaurants[h_restaurant["id"]] = { "photo" => h_restaurant["photo"]["pc"]["m"], "name" => h_restaurant["name"], 
                                                   "genre" => h_restaurant["genre"], "address" => h_restaurant["address"], 
                                                   "open" => h_restaurant["open"], "close" => h_restaurant["close"],
                                                   "urls" => h_restaurant["urls"]["pc"], "large_area" => h_restaurant["large_area"],
                                                   "middle_area" => h_restaurant["middle_area"] }
            end
            logger.debug("----------------------@h_restaurants #{@h_restaurants}")
          end
        end
        
        # 店舗情報保存のための準備処理
        def processing_restaurant_params( r_name, r_address, r_open_time, r_close_day, r_hotpepper_id, r_url )
            # 店舗情報入力フォームに未入力の欄があったときの処理
          if r_name.present?
            @name = r_name
          else
            @name = nil
          end
          
          if r_address.present?
            @address = r_address
          else
            @address = nil
          end
        
          if r_open_time.present?
            @open_time = r_open_time
          else
            @open_time = nil
          end
        
          if r_close_day.present?
            @close_day = r_close_day
          else
            @close_day = nil
          end
        
          if r_hotpepper_id.present?
            @hotpepper_id = r_hotpepper_id
          else
            @hotpepper_id = nil
          end
        
          if r_url.present?
            @url = r_url
          else
            @url = nil
          end
        end
end
