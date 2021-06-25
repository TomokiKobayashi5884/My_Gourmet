class PostsController < ApplicationController
  
  require 'net/http'
  require 'json'
  # 1ページあたりの表示件数
  PER = 10
  
  def index
    # @posts = Post.all.order("updated_at DESC")
    @posts = Post.order("updated_at DESC").page(params[:page]).per(PER)
  end

  def show
  end

  def new
    @post = Post.new
    @restaurant = Restaurant.new(restaurant_params)
    
    @large_areas = LargeArea.all
    @middle_areas = MiddleArea.all
    @genres = Genre.all
   
   # 検索条件入力部分
    if params[:keyword] != nil
      keyword = params[:keyword].strip
    else
      keyword = ""
    end
    # @keyword = keyword
    
    if params[:large_area_selected].present?
      large_area = params[:large_area_selected]
    else
      large_area = ""
    end
    # @large_area_selected = large_area
    
    if params[:middle_area_selected].present?
      middle_area = params[:middle_area_selected]
    else
      middle_area = ""
    end
    # @middle_area_selected = middle_area
    
    if params[:genre_selected].present?
      genre = params[:genre_selected]
    else
      genre = ""
    end
    # @genre_selected = genre
    
    # 検索用パラメータ
    keyid = ENV["KEYID"]
    data_format = "json"
    search_params = { "key": keyid, "keyword": keyword, "large_area": large_area, "middle_area": middle_area, "genre": genre, "format": data_format }
    
    # 入力された条件を元にホットペッパーで店舗を検索
    search(search_params)
    logger.debug("============================ restaurant hash = #{@h_restaurants}")
    
    # ホットペッパー検索のページネーション
    # @hot_restaurants = @h_restaurants.page(params[:page]).per(PER)
    #   respond_to do |format|
    #   format.html { render "hotpepper_search" }
    #   format.json { render "hotpepper_search.json.jbuilder" }
    # end
  end
  
  # def middle_area_select
  #   if request.xhr?
  #     render partial: 'middle_area', locals: { large_area_id: params[:large_area_id]}
  #   end
  # end
  
  # ホットペッパーから店舗情報を探すメソッド
  # def search_by_hotpepper
  #   # 検索条件入力部分
  #   if params[:keyword] != nil
  #     keyword = params[:keyword].strip
  #   else
  #     keyword = ""
  #   end
  #   @keyword = keyword
    
  #   if params[:large_area_select].present?
  #     large_area = params[:large_area_select]
  #   else
  #     large_area = ""
  #   end
  #   @large_area_selected = large_area
    
  #   if params[:middle_area_select].present?
  #     middle_area = params[:middle_area_select]
  #   else
  #     middle_area = ""
  #   end
  #   @middle_area_selected = middle_area
    
  #   if params[:genre_select].present?
  #     genre = params[:genre_select]
  #   else
  #     genre = ""
  #   end
  #   @genre_selected = genre
    
  #   # 検索用パラメータ
  #   keyid = ENV["KEYID"]
  #   data_format = "json"
  #   search_params = { "key": keyid, "keyword": @keyword, "large_area": @large_area_selected, "middle_area": @middle_area_selected, "genre": @genre_selected, "format": data_format }
    
  #   # 入力された条件を元にホットペッパーで店舗を検索
  #   search(search_params)
  #   logger.debug("============================ restaurant hash = #{@h_restaurants}")
  # end


  def create
    redirect_flag = false
    @post = Post.new(post_params)
    logger.debug("============================ post params = #{params[:post]}")
    logger.debug("============================ restaurant params = #{params[:post][:restaurant]}")
    # if params[:post][:restaurant][:large_area_code].present? && params[:post][:restaurant][:middle_area_code].present?
    
    
    # 店舗情報がフォームに全く入力されていない場合
    if params[:post][:restaurant][:name] == ""
      # && params[:post][:restaurant][:address] === "" && params[:post][:restaurant][:open_time] === ""
      # && params[:post][:restaurant][:close_day] === "" && params[:post][:restaurant][:large_area_code] === "" && params[:post][:restaurant][:middle_area_code] ===""
       
      @post.restaurant_id = nil
    # 店舗情報がフォームに入力されている場合
    else
    # large_area_code, middle_area_codeを対応するlarge_area_id, middle_area_idに変換
      if params[:post][:restaurant][:large_area_code].present?
        @large_area = LargeArea.find_by(large_area_code: params[:post][:restaurant][:large_area_code]).id
      else
        @large_area = nil
      end
      
      if params[:post][:restaurant][:middle_area_code].present?
        @middle_area = MiddleArea.find_by(middle_area_code: params[:post][:restaurant][:middle_area_code]).id
      else
        @middle_area = nil
      end
      
      # 保存しようとするレストラン情報がデータベースに存在するかチェック(あれば、@restaurantは既存のデータに,なければ新規で保存)
      if Restaurant.find_by(address: params[:post][:restaurant][:address])
         logger.debug("============================ restaurant exist")
         
          @restaurant = Restaurant.find_by(address: params[:post][:restaurant][:address])
          logger.debug("============================ @restaurant = #{@restaurant}")
      else
         logger.debug("============================ restaurant not exist")
         
          @restaurant = Restaurant.new(name: params[:post][:restaurant][:name],
                                       address: params[:post][:restaurant][:address],
                                       open_time: params[:post][:restaurant][:open_time],
                                       close_day: params[:post][:restaurant][:close_day],
                                       hotpepper_id: params[:post][:restaurant][:hotpepper_id],
                                       large_area_id: @large_area,
                                       middle_area_id: @middle_area,
                                       url: params[:post][:restaurant][:url])
                                       
          logger.debug("============================ @restaurant = #{@restaurant}")
          @restaurant.save
      end        
      
      # @restaurantと紐付けて、@postも保存      
      @post.restaurant_id = @restaurant.id
      # logger.debug("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ post_params #{params[:post]}")
      # @genre = Genre.find_by(genre_code: params[:post][:genre_code]) 
      # logger.debug("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ genre #{@genre}")
      # @post.genre_id = @genre.id
      
   
    
      
    end
      logger.debug("============================ @post = #{@post}")
      @post.save

      if @post.save
        redirect_flag = true
      end
    
      if redirect_flag
         flash[:notice] = "投稿しました。"
         redirect_to root_path
      else
         flash[:notice] = "投稿に失敗しました。"
         render :new
      end
      
   
    
    # else
    #     logger.debug("============================ large_area middle_area 受け取れなかった")
    #         flash[:notice] = "large_area_code等が選択されてなくえて投稿に失敗しました。"
    #         render :new     
    # end
  end

  def edit
  end

  def update
  end

  def destroy
  end
  
  private
    #投稿保存時のストロングパラメータを設定
    def post_params
      params.require(:post).permit(:image, :title, :genre_id, :ate, :content, :user_id)
    end
    
    def restaurant_params
      params.permit(:name, :address, :phone, :open_time, :close_day, :hotpepper_id, :large_area_id, :middle_area_id, :url)
    end
    
    # ホットペッパーで店舗を検索し、ハッシュに格納する処理
    def search(search_params)
      @h_restaurants = Hash.new { |h,k| h[k] = {} }
      uri = URI.parse("http://webservice.recruit.co.jp/hotpepper/gourmet/v1/")
      uri.query = URI.encode_www_form(search_params)  
  
      json_res = Net::HTTP.get uri
      
      response = JSON.load(json_res)
      
      # body = JSON.parse(response.body)
      # meta = body["meta"]
      
      if response["results"].has_key?("error")
        puts "エラーが発生しました！"
        @h_restaurants = {}
      else
        # 検索条件にマッチする全件数
        @available_restaurants = response["results"]["results_available"]
        # 検索結果にマッチしたレストランの情報
        response["results"]["shop"].each do |h_restaurant|
        @h_restaurants[h_restaurant["id"]] = {"photo" => h_restaurant["photo"]["pc"]["m"], "name" => h_restaurant["name"], 
                                            "genre" => h_restaurant["genre"], "address" => h_restaurant["address"], 
                                            "open" => h_restaurant["open"], "close" => h_restaurant["close"],
                                            "urls" => h_restaurant["urls"]["pc"], "large_area" => h_restaurant["large_area"],
                                            "middle_area" => h_restaurant["middle_area"]  
                                          }
                      
        # @hot_restaurants = Kaminari.paginate_array(@h_restaurants, total_count: meta["total_count"])
        # .page(meta["current_page"]).per(meta["limit_value"])
        
                            
        end
      end
    end   
end
