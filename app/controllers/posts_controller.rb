class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  
  require 'net/http'
  require 'json'
  # 1ページあたりの表示件数
  PER = 10
  # ランキング表示件数
  TOP = 3
 
  
  def index
    @large_areas = LargeArea.all
    @middle_areas = MiddleArea.all
    @genres = Genre.all
    # -----------------------------------投稿検索処理------------------------------------------
    if params[:large_area_id].present?
      restaurant_id = Restaurant.where(large_area_id: params[:large_area_id]).pluck(:id)
      post_large_area = Post.where(restaurant_id: restaurant_id).pluck(:id)
    else
      post_large_area = Post.all.pluck(:id)
    end
    
    if params[:middle_area_id].present?
      restaurant_id = Restaurant.where(middle_area_id: params[:middle_area_id]).pluck(:id)
      post_middle_area = Post.where(restaurant_id: restaurant_id).pluck(:id)
    else
      post_middle_area = Post.all.pluck(:id)
    end
    
    if params[:genre_id].present?
      post_genre = Post.where(genre_id: params[:genre_id]).pluck(:id)
    else
      post_genre = Post.all.pluck(:id)
    end
    
    if params[:keyword].present?
      @posts = Post.keyword_search(params[:keyword].strip).where(" id IN (?) and id IN (?) and id IN (?)", post_large_area, post_middle_area, post_genre)
              .order("created_at DESC").page(params[:page]).per(PER)
    else
      @posts = Post.where(" id IN (?) and id IN (?) and id IN (?)", post_large_area, post_middle_area, post_genre)
              .order("created_at DESC").page(params[:page]).per(PER)
    end
    # ------------------------------------ランキング用の投稿データ-------------------------------------------
    rank_in_posts_ids = Favorite.group(:post_id).order('count(post_id) DESC').limit(TOP).pluck(:post_id)
    @ranking = Post.find(rank_in_posts_ids)
  end
  
  
  def show
      @comments = @post.comments
      @comment = @post.comments.new
  end


  def new
    logger.debug("---------------------- posts_new")
    @post = Post.new
    @restaurant = Restaurant.new
    @large_areas = LargeArea.all
    @middle_areas = MiddleArea.all
    @genres = Genre.all
    # ---------------------------------店舗検索処理----------------------------------------
  # ホットペッパーで検索の条件入力部分
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
    logger.debug("----------------------params[:start] #{params[:start]}")
    logger.debug("----------------------params[:page] #{params[:page]}")
    if params[:start].present?
      start = (params[:start].strip.to_i * 10) - 9
    else
      start = 1
    end
    
    # 店舗情報をフォームに渡す用のインスタンス
    if params[:name].present?
      @name = params[:name]
    else
      @name = ""
    end
    
    if params[:address].present?
      @address = params[:address]
    else
      @address = ""
    end
    
    if params[:open_time].present?
      @open_time = params[:open_time]
    else
      @open_time = ""
    end
    
    if params[:close_day].present?
      @close_day = params[:close_day]
    else
      @close_day = ""
    end
    
    if params[:hotpepper_id].present?
      @hotpepper_id = params[:hotpepper_id]
    else
      @hotpepper_id = ""
    end
    
    if params[:url].present?
      @url = params[:url]
    else
      @url = ""
    end
    
    if params[:large_area_code].present?
      @large_area_code = params[:large_area_code]
    else
      @large_area_code = ""
    end
    
    if params[:middle_area_code].present?
      @middle_area_code = params[:middle_area_code]
    else
      @middle_area_code = ""
    end
    
    
    # 検索用パラメータ
    keyid = ENV["KEYID"]
    data_format = "json"
    # start = params[:start]
    search_params = { "key": keyid, "keyword": keyword, "large_area": large_area, "middle_area": middle_area, "genre": genre, "format": data_format, "start": start }
    
    # 入力された条件を元にホットペッパーで店舗を検索
    search(search_params)
    
  #   # ホットペッパー検索のページネーション
    # @hot_restaurants = @h_restaurants.page(params[:page]).per(PER)
    # respond_to do |format|
    #   format.html { render "hotpepper_search" }
    #   format.json { render "hotpepper_search.json.jbuilder" }
    # end
  end
  
  
  # 都道府県入力からエリアプルダウン(投稿検索とホットペッパーで店舗検索用)
  def middle_area_select
    if params[:large_area_id].present?
      render partial: 'select_middle_area', locals: { large_area_id: params[:large_area_id], middle_area_id: params[:middle_area_id] }
    else
      render partial: 'select_middle_area_for_hot', locals: { large_area_code: params[:large_area_code] }
    end
  end
  
  # 都道府県入力からエリアプルダウン(newとedit用)
  def middle_area_select_for_ne
    if params[:large_area_code].present?
      render partial: 'select_middle_area_for_edit', locals: { large_area_code: params[:large_area_code], middle_area_code: params[:middle_area_code] }
    else
      # render partial: 'select_middle_area_for_new', locals: { large_area_code: params[:large_area_code] }
    end
  end
  
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
    if params[:post][:title] === ""
      params[:post][:title] = Genre.find(params[:post][:genre_id]).name
    end
    @post = Post.new(post_params)
    
    logger.debug("============================ post params = #{params[:post]}")
    logger.debug("============================ restaurant params = #{params[:post][:restaurant]}")
    logger.debug("============================ restaurant name = #{params[:post][:restaurant][:name]}")
    logger.debug("============================ restaurant address = #{params[:post][:restaurant][:address]}")
    logger.debug("============================ restaurant open_time = #{params[:post][:restaurant][:open_time]}")
    logger.debug("============================ restaurant close_day = #{params[:post][:restaurant][:close_day]}")
    logger.debug("============================ restaurant hotpepper_id = #{params[:post][:restaurant][:hotpepper_id]}")
    logger.debug("============================ restaurant url = #{params[:post][:restaurant][:url]}")
    logger.debug("============================ restaurant large_area_code = #{params[:post][:restaurant][:large_area_code]}")
    logger.debug("============================ restaurant middle_area_code = #{params[:restaurant][:middle_area_code]}")
    # if params[:post][:restaurant][:large_area_code].present? && params[:post][:restaurant][:middle_area_code].present?
    
    restaurant_save_flag = false
    # 店名が入力されていない場合は店舗情報を投稿に紐付けない
    if params[:post][:restaurant][:name] == ""
      @post.restaurant_id = nil
      restaurant_save_flag = true
    # 店舗情報がフォームに入力されている場合
    else
    # 　large_area_code,middle_area_codeを対応するlarge_area_id,middle_area_idに変換
      if params[:post][:restaurant][:large_area_code].present?
        large_area = LargeArea.find_by(large_area_code: params[:post][:restaurant][:large_area_code]).id
        
        if params[:restaurant][:middle_area_code].present?
          middle_area = MiddleArea.find_by(middle_area_code: params[:restaurant][:middle_area_code]).id
        else
          middle_area = nil
        end
      else
        large_area = nil
        middle_area = nil
      end
      
      # フォームに未入力の欄があったときの処理
      if params[:post][:restaurant][:name].present?
        name = params[:post][:restaurant][:name]
      else
        name = nil
      end
      
      if params[:post][:restaurant][:address].present?
        address = params[:post][:restaurant][:address]
      else
        address = nil
      end

      if params[:post][:restaurant][:open_time].present?
        open_time = params[:post][:restaurant][:open_time]
      else
        open_time = nil
      end

      if params[:post][:restaurant][:close_day].present?
        close_day = params[:post][:restaurant][:close_day]
      else
        close_day = nil
      end

      if params[:post][:restaurant][:hotpepper_id].present?
        hotpepper_id = params[:post][:restaurant][:hotpepper_id]
      else
        hotpepper_id = nil
      end

      if params[:post][:restaurant][:url].present?
        url = params[:post][:restaurant][:url]
      else
        url = nil
      end
      
      # 保存しようとするレストラン情報がデータベースに存在するかチェック(あれば、@restaurantは既存のデータに,なければ新規で保存)
      if Restaurant.find_by(address: params[:post][:restaurant][:address]) && params[:post][:restaurant][:address] != nil
         logger.debug("============================ restaurant exist")
         
          @restaurant = Restaurant.find_by(address: params[:post][:restaurant][:address])
          restaurant_save_flag = true
      else
         logger.debug("============================ restaurant not exist")
          @restaurant = Restaurant.new(name: name,
                                       address: address,
                                       open_time: open_time,
                                       close_day: close_day,
                                       hotpepper_id: hotpepper_id,
                                       large_area_id: large_area,
                                       middle_area_id: middle_area,
                                       url: url)
          if @restaurant.save
              restaurant_save_flag = true
          end
      end
      # @postを@restaurantと紐付ける  
      @post.restaurant_id = @restaurant.id
    end
    
    if restaurant_save_flag
      if @post.save
        redirect_flag = true
        # 投稿する食べ物が食べたい物なら、そのまま食べたい物リストに追加
        if @post.ate == false
          @favorite = Favorite.create(user_id: current_user.id, post_id: @post.id)
        end
      end
    end
    
    if redirect_flag
      flash[:notice] = "投稿しました。"
        redirect_to root_path
    else
      flash.now[:alert] = "投稿に失敗しました。"
      @large_areas = LargeArea.all
      @middle_areas = MiddleArea.all
      @genres = Genre.all
      # @post = Post.new(post_params)
      # @restaurant = Restaurant.new(name: name,
      #                             address: address,
      #                             open_time: open_time,
      #                             close_day: close_day,
      #                             hotpepper_id: hotpepper_id,
      #                             large_area_code: params[:post][:restaurant][:large_area_code],
      #                             middle_area_code: params[:restaurant][:middle_area_code],
      #                             url: url)
      logger.debug("----------------------------------params[:restaurant][:middle_area_code] #{params[:restaurant][:middle_area_code]}")
      render :new
    end
  end


  def edit
    @large_areas = LargeArea.all
    @middle_areas = MiddleArea.all
    @genres = Genre.all
    
    if @post.restaurant_id.present?
      restaurant_id = @post.restaurant_id
      @restaurant = Restaurant.find(restaurant_id)
      
      params[:large_area_code] = LargeArea.find(@restaurant.large_area_id).large_area_code
      params[:middle_area_code] = MiddleArea.find(@restaurant.middle_area_id).middle_area_code
    else
      @restaurant = Restaurant.new
    end
  end


  def update
    redirect_flag = false
    restaurant_save_flag = false
    # 店舗情報がフォームに全く入力されていない場合
    if params[:post][:restaurant][:name] == "" && params[:post][:restaurant][:address] === ""
      # && params[:post][:restaurant][:open_time] === "" && params[:post][:restaurant][:close_day] === "" 
       
      @post.restaurant_id = nil
      restaurant_save_flag = true
    # 店舗情報がフォームに入力されている場合
    else
      # large_area_code,middle_area_codeを対応するlarge_area_id,middle_area_idに変換
      if params[:post][:restaurant][:large_area_code].present?
        large_area = LargeArea.find_by(large_area_code: params[:post][:restaurant][:large_area_code]).id
        
        if params[:post].has_key?(:middle_area_code)
          middle_area = MiddleArea.find_by(middle_area_code: params[:post][:middle_area_code]).id
        elsif params[:restaurant].has_key?(:middle_area_code)
          middle_area = MiddleArea.find_by(middle_area_code: params[:restaurant][:middle_area_code]).id
        else
          middle_area = nil
        end
      else
        large_area = nil
        middle_area = nil
      end
      
      # フォームに未入力の欄があったときの処理
      if params[:post][:restaurant][:name].present?
        name = params[:post][:restaurant][:name]
      else
        name = nil
      end
      
      if params[:post][:restaurant][:address].present?
        address = params[:post][:restaurant][:address]
      else
        address = nil
      end

      if params[:post][:restaurant][:open_time].present?
        open_time = params[:post][:restaurant][:open_time]
      else
        open_time = nil
      end

      if params[:post][:restaurant][:close_day].present?
        close_day = params[:post][:restaurant][:close_day]
      else
        close_day = nil
      end

      if params[:post][:restaurant][:hotpepper_id].present?
        hotpepper_id = params[:post][:restaurant][:hotpepper_id]
      else
        hotpepper_id = nil
      end

      if params[:post][:restaurant][:url].present?
        url = params[:post][:restaurant][:url]
      else
        url = nil
      end
      
      # 保存しようとする店舗情報がデータベースに存在するかチェック(あればそのデータを更新、,なければ新規作成)
      if Restaurant.find_by(name: params[:post][:restaurant][:name], address: params[:post][:restaurant][:address])
        logger.debug("============================ restaurant exist")
        
        @restaurant = Restaurant.find_by(address: params[:post][:restaurant][:address])
        @restaurant.update(name: name,
                           address: address,
                           open_time: open_time,
                           close_day: close_day,
                           hotpepper_id: hotpepper_id,
                           large_area_id: large_area,
                           middle_area_id: middle_area,
                           url: url)
          restaurant_save_flag = true
          logger.debug("============================ restaurant update")
      else
        logger.debug("============================ name #{name}")
        logger.debug("============================ address #{address}")
        logger.debug("============================ open_time #{open_time}")
        logger.debug("============================ close_day #{close_day}")
        logger.debug("============================ hotpepper_id #{hotpepper_id}")
        logger.debug("============================ large_area #{large_area}")
        logger.debug("============================ middle_area #{middle_area}")
        logger.debug("============================ url #{url}")
        logger.debug("============================ restaurant not exist")
        @restaurant = Restaurant.new(name: name,
                                     address: address,
                                     open_time: open_time,
                                     close_day: close_day,
                                     hotpepper_id: hotpepper_id,
                                     large_area_id: large_area,
                                     middle_area_id: middle_area,
                                     url: url)
        if @restaurant.save
          restaurant_save_flag = true
          logger.debug("============================ restaurant save")
          
        end
      end        
      # @postを@restaurantと紐付ける      
      @post.restaurant_id = @restaurant.id
      logger.debug("------------------------------@restaurant #{@restaurant}")
      logger.debug("------------------------------@post.restaurant_id #{@post.restaurant_id}")
      
    end
    
    if restaurant_save_flag
      # 更新する項目だけを更新
      # 料理名が未入力の場合はジャンル名を料理名として保存
      if params[:post][:title] === ""
        params[:post][:title] = Genre.find(params[:post][:genre_id]).name 
      end
      @post.title = params[:post][:title]
      
      if params[:post][:content].present?
        @post.content = params[:post][:content]
      else
        @post.content = nil
      end
      
      if params[:post][:image]
        @post.image = params[:post][:image]
      end
      
      @post.ate = params[:post][:ate]
      @post.genre_id = params[:post][:genre_id]
      logger.debug("----------------------------params[:post][:title] #{params[:post][:title]}")
      logger.debug("----------------------------params[:post][:content] #{params[:post][:content]}")
      logger.debug("----------------------------params[:post][:ate] #{params[:post][:ate]}")
      logger.debug("----------------------------params[:post][:image] #{params[:post][:image]}")
      logger.debug("----------------------------params[:post][:user_id] #{params[:post][:user_id]}")
      logger.debug("----------------------------params[:post][:genre_id] #{params[:post][:genre_id]}")
      if @post.save
        redirect_flag = true
        logger.debug("============================ post update")
        # 食べたい物リストに追加するかの処理
        if @post.ate == false
          @favorite = Favorite.create(user_id: current_user.id, post_id: @post.id)
        else
          @favorite = Favorite.find_by(user_id: current_user.id, post_id: @post.id)
          if @favorite.present?
            @favorite.destroy
          end
          
        end
      end
    end
    
    if redirect_flag
      flash[:notice] = "投稿を編集しました。"
      redirect_to root_path
    else
      flash[:alert] = "投稿の編集に失敗しました。"
      @large_areas = LargeArea.all
      @middle_areas = MiddleArea.all
      @genres = Genre.all
      
      # if @post.restaurant_id.present?
      #   restaurant_id = @post.restaurant_id
      #   @restaurant = Restaurant.find(restaurant_id)
        
      #   params[:large_area_code] = LargeArea.find(@restaurant.large_area_id).large_area_code
      #   params[:middle_area_code] = MiddleArea.find(@restaurant.middle_area_id).middle_area_code
      # else
      #   @restaurant = Restaurant.new
      # end
      # @post.attributes = params[:post]
      # @restaurant.attributes = params[:post][:restaurant]
      render :edit
    end
  end


  def destroy
    @post.destroy
    if @post.destroy
      flash[:notice] = "投稿を削除しました。"
      redirect_back(fallback_location: mypage_post_list_users_path)
    else
      flash[:alert] = "投稿を削除できませんでした。"
      redirect_back(fallback_location: mypage_post_list_users_path)
    end
  end
  
  
  private
    
    def set_post
      @post = Post.find(params[:id])
    end
    
    
    #投稿保存時のストロングパラメータを設定
    def post_params
      params.require(:post).permit(:image, :title, :genre_id, :ate, :content, :user_id, :image_cache)
    end
    
    
    # def restaurant_params
    #   params.require(:restaurant)permit(:name, :address, :phone, :open_time, :close_day, :hotpepper_id, :large_area_id, :middle_area_id, :url)
    # end
    
    
    # ホットペッパーで店舗を検索し、ハッシュに格納する処理
    def search(search_params)
      @h_restaurants = Hash.new { |h,k| h[k] = {} }
      uri = URI.parse("http://webservice.recruit.co.jp/hotpepper/gourmet/v1/")
      uri.query = URI.encode_www_form(search_params)  
  
      json_res = Net::HTTP.get uri
      
      response = JSON.load(json_res)
      
      if response["results"].has_key?("error")
        # puts "エラーが発生しました！"
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
                                            "middle_area" => h_restaurant["middle_area"]}
        
        
        # @current_page = params[:page].nil? ? 1 : params[:page].to_i
        @max_page = (@available_restaurants.to_f / 10).ceil
        
        if params[:page] === "≪"
          @current_page = 1
        elsif params[:page] === "≫"
          @current_page = @max_page
        else
          @current_page = (params[:start].to_i + 9) / 10
        end
        
        @pagination = {}
        @pagination["≪"] = 1 if @current_page >= 3
        @pagination["<"] = @current_page - 1 if @current_page != 1
        
        if @current_page >= @max_page - 2
          @pagination.merge!({@max_page - 2 => @max_page - 2, @max_page - 1 => @max_page - 1, @max_page => @max_page})
          delete_list = [0, -1]
          @pagination.delete_if do |page, start|
            delete_list.include?(start)
          end
        else
          @pagination.merge!({@current_page => @current_page, @current_page + 1 => @current_page + 1, @current_page + 2 => @current_page + 2})
        end
        
        @pagination[">"] = @current_page + 1 if @current_page != @max_page
        @pagination["≫"] = @max_page if @current_page <= @max_page - 2
          
          
          
        # @pagination = [*1..@max_page]
        
        
        
        # @page = params[:page].to_i
        
        # if all_page > 10
        #   first = [1,  @page - 4].max
        #   first = [first, @max_page - 9].min
        #   last  = [10, @page + 5].max
        #   last  = [last, @max_page].min
        # else
        #   @pages = [*1..@max_page]
        # end
        
        end
      end
    end   
end
