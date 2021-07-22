class PostsController < ApplicationController
  
  include CommonHelper
  
  
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  
  require 'net/http'
  require 'json'
  # 1ページあたりの表示件数（index）
  PER = 10
  # ランキング表示件数
  TOP = 3
  # 1ページあたりの表示件数（ホットペッパー店舗検索）
  HOTPEPPER_PER = 10
 
  
  def index
    @large_areas = LargeArea.all
    @middle_areas = MiddleArea.all
    @genres = Genre.all
    # -----------------------------------投稿検索処理------------------------------------------
    
    if params[:large_area_id].present?
      restaurant_id = Restaurant.where( large_area_id: params[:large_area_id] ).pluck(:id)
      post_large_area = Post.where( restaurant_id: restaurant_id ).pluck(:id)
    else
      post_large_area = Post.all.pluck(:id)
    end
    
    if params.has_key?(:post)
      if params[:post][:middle_area_id].present?
        restaurant_id = Restaurant.where(middle_area_id: params[:post][:middle_area_id] ).pluck(:id)
        post_middle_area = Post.where( restaurant_id: restaurant_id ).pluck(:id)
      else
        post_middle_area = Post.all.pluck(:id)
      end
    else
      post_middle_area = Post.all.pluck(:id)
    end
    
    if params[:genre_id].present?
      post_genre = Post.where( genre_id: params[:genre_id] ).pluck(:id)
    else
      post_genre = Post.all.pluck(:id)
    end
    
    if params[:keyword].present?
      @posts = Post.search_by_keyword( params[:keyword].strip ).where( "id IN (?) and id IN (?) and id IN (?)", post_large_area, post_middle_area, post_genre )
              .order("created_at DESC").page(params[:page]).per(PER)
    else
      @posts = Post.where( "id IN (?) and id IN (?) and id IN (?)", post_large_area, post_middle_area, post_genre )
              .order("created_at DESC").page(params[:page]).per(PER)
    end
    
    # restaurant_id_large_area = Restaurant.search_restaurant_by_large_area(params[:large_area_id])
    # if params.has_key?(:post)
    #   restaurant_id_middle_area = Restaurant.search_restaurant_by_middle_area(params[:post][:middle_area_id])
    # else
    #   restaurant_id_middle_area = nil
    # end
    # @posts = Post.search_by_keyword(params[:keyword]).search_by_large_area(restaurant_id_large_area)
    #         .search_by_middle_area(restaurant_id_middle_area).search_by_genre(params[:genre_id])
    #         .order("created_at DESC").page(params[:page]).per(PER)
    
    # ------------------------------------ランキング用の投稿データ-------------------------------------------
    rank_in_posts_ids = Favorite.group(:post_id).order('count(post_id) DESC').limit(TOP).pluck(:post_id)
    @ranking = Post.find(rank_in_posts_ids)
  end
  
  
  def show
      @comments = Comment.where( post_id: @post.id )
      @comment = @post.comments.new
  end


  def new
    @post = Post.new
    @restaurant = Restaurant.new
    @large_areas = LargeArea.all
    @middle_areas = MiddleArea.all
    @genres = Genre.all
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
    logger.debug("----------------------params[:start] #{params[:start]}")
    # 検索結果の何件目から出力するか
    if params[:start].present?
      start = params[:start]
      logger.debug("------------------------start #{start}")
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
      @large_area_code = params[:large_area_code]
    else
      @large_area_code = nil
    end
      
    if params[:middle_area_code].present?
      @middle_area_code = params[:middle_area_code]
    else
      @middle_area_code = nil
    end
    
  end
  
  
  # 都道府県入力からエリアプルダウン(投稿検索とホットペッパーで店舗検索用)
  def middle_area_select
    if params[:large_area_id].present?
      render partial: 'select_middle_area', locals: { large_area_id: params[:large_area_id], middle_area_id: params[:middle_area_id] }
    else
      render partial: 'select_middle_area_for_hot', locals: { large_area_code: params[:large_area_code] }
    end
  end
  
  
  # 都道府県入力からエリアプルダウン(newとedit用)(required付き)
  def middle_area_select_for_ne
    if params[:large_area_code].present?
      render partial: 'select_middle_area_for_ne', locals: { large_area_code: params[:large_area_code], middle_area_code: params[:middle_area_code] }
    end
  end
  

  def create
    redirect_flag = false
    restaurant_save_flag = false
    
    @post = Post.new(post_params)
    
    # large_area_code,middle_area_codeを対応するlarge_area_id,middle_area_idに変換
    if params[:post][:restaurant][:large_area_code].present?
      @large_area = LargeArea.find_by( large_area_code: params[:post][:restaurant][:large_area_code] ).id
      
      if params[:post].has_key?(:middle_area_code)
        @middle_area = MiddleArea.find_by( middle_area_code: params[:post][:middle_area_code] ).id
      elsif params[:post][:restaurant].has_key?(:middle_area_code)
        @middle_area = MiddleArea.find_by( middle_area_code: params[:post][:restaurant][:middle_area_code] ).id
      elsif params[:restaurant].has_key?(:middle_area_code)
        @middle_area = MiddleArea.find_by( middle_area_code: params[:restaurant][:middle_area_code] ).id
      else
        @middle_area = nil
      end
    else
      @large_area = nil
      @middle_area = nil
    end
    
    # 店名が入力されていない場合は店舗情報を保存せず、投稿に紐付けない
    if params[:post][:restaurant][:name] == ""
      @post.restaurant_id = nil
      restaurant_save_flag = true
    # 店舗情報がフォームに入力されている場合
    else
      # 店舗情報のパラメータを加工
      processing_restaurant_params( params[:post][:restaurant][:name], params[:post][:restaurant][:address], params[:post][:restaurant][:open_time],
                                    params[:post][:restaurant][:close_day], params[:post][:restaurant][:hotpepper_id], params[:post][:restaurant][:url] )
      
      # 保存しようとする店舗情報がデータベースに存在するかチェック(あれば、@restaurantは既存のデータに,なければ新規で保存)
      if Restaurant.find_by( address: params[:post][:restaurant][:address] ) && params[:post][:restaurant][:address] != nil
         logger.debug("============================ restaurant exist")
         
          @restaurant = Restaurant.find_by( address: params[:post][:restaurant][:address] )
          restaurant_save_flag = true
          # @postを@restaurantと紐付ける  
          @post.restaurant_id = @restaurant.id
      else
         logger.debug("============================ restaurant not exist")
          @restaurant = Restaurant.new( name: @name,
                                        address: @address,
                                        open_time: @open_time,
                                        close_day: @close_day,
                                        hotpepper_id: @hotpepper_id,
                                        large_area_id: @large_area,
                                        middle_area_id: @middle_area,
                                        url: @url )
          if @restaurant.save
              restaurant_save_flag = true
              logger.debug("============================ new restaurant save")
              # @postを@restaurantと紐付ける  
              @post.restaurant_id = @restaurant.id
          end
      end
    end
    
    if restaurant_save_flag
      # 料理名が未入力の場合はジャンル名を料理名として保存
      if params[:post][:title] === ""
        params[:post][:title] = Genre.find(params[:post][:genre_id]).name
      end
      @post.title = params[:post][:title]
      
      if @post.save
        redirect_flag = true
        # 食べたい物リストに追加するどうかかの処理
        if @post.ate == false
          @favorite = Favorite.create( user_id: current_user.id, post_id: @post.id )
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
      
      if @post.restaurant_id == nil
        @restaurant = Restaurant.new
      end
      # 入力されていた都道府県とエリアコードをフォームに再セット
      @submitted_large_area_code = LargeArea.find(@large_area).large_area_code if @large_area != nil
      @submitted_middle_area_code = MiddleArea.find(@middle_area).middle_area_code if @middle_area != nil
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
    
    # large_area_code,middle_area_codeを対応するlarge_area_id,middle_area_idに変換
    if params[:post][:restaurant][:large_area_code].present?
      @large_area = LargeArea.find_by( large_area_code: params[:post][:restaurant][:large_area_code] ).id
      
      if params[:post].has_key?(:middle_area_code)
        @middle_area = MiddleArea.find_by( middle_area_code: params[:post][:middle_area_code] ).id
      elsif params[:post][:restaurant].has_key?(:middle_area_code)
        @middle_area = MiddleArea.find_by( middle_area_code: params[:post][:restaurant][:middle_area_code] ).id
      elsif params[:restaurant].has_key?(:middle_area_code)
        @middle_area = MiddleArea.find_by( middle_area_code: params[:restaurant][:middle_area_code] ).id
      else
        @middle_area = nil
      end
    else
      @large_area = nil
      @middle_area = nil
    end
    
    # 店名が入力されていない場合は店舗情報を保存せず、投稿に紐付けない
    if params[:post][:restaurant][:name] == ""
      @post.restaurant_id = nil
      restaurant_save_flag = true
    # 店舗情報がフォームに入力されている場合
    else
      # 店舗情報のパラメータを加工
      processing_restaurant_params( params[:post][:restaurant][:name], params[:post][:restaurant][:address], params[:post][:restaurant][:open_time],
                                    params[:post][:restaurant][:close_day], params[:post][:restaurant][:hotpepper_id], params[:post][:restaurant][:url] )
      
      # 保存しようとする店舗情報がデータベースに存在するかチェック(あればそのデータを更新、,なければ新規作成)
      if Restaurant.find_by( name: params[:post][:restaurant][:name], address: params[:post][:restaurant][:address] )
        logger.debug("============================ restaurant exist")
        
        @restaurant = Restaurant.find_by( address: params[:post][:restaurant][:address] )
        if @restaurant.update( name: @name,
                               address: @address,
                               open_time: @open_time,
                               close_day: @close_day,
                               hotpepper_id: @hotpepper_id,
                               large_area_id: @large_area,
                               middle_area_id: @middle_area,
                               url: @url )
          # @postを@restaurantと紐付ける      
          @post.restaurant_id = @restaurant.id
          restaurant_save_flag = true
          logger.debug("============================ restaurant update")
        end
      else
        logger.debug("============================ restaurant not exist")
        @restaurant = Restaurant.new( name: @name,
                                      address: @address,
                                      open_time: @open_time,
                                      close_day: @close_day,
                                      hotpepper_id: @hotpepper_id,
                                      large_area_id: @large_area,
                                      middle_area_id: @middle_area,
                                      url: @url )
        if @restaurant.save
          logger.debug("============================ restaurant save")
          # @postを@restaurantと紐付ける      
          @post.restaurant_id = @restaurant.id
          restaurant_save_flag = true
        end
      end        
    end
    
    if restaurant_save_flag
      # 料理名が未入力の場合はジャンル名を料理名として保存
      if params[:post][:title] === ""
        params[:post][:title] = Genre.find(params[:post][:genre_id]).name 
      end
      @post.title = params[:post][:title]
      
      if @post.update(post_params)
        redirect_flag = true
        logger.debug("============================ post update")
        # 食べたい物リストに追加するどうかかの処理
        if @post.ate == false
          @favorite = Favorite.create( user_id: current_user.id, post_id: @post.id )
        else
          @favorite = Favorite.find_by( user_id: current_user.id, post_id: @post.id )
          if @favorite.present?
            @favorite.destroy
          end
          
        end
      end
    end
    
    if redirect_flag
      flash[:notice] = "投稿を編集しました。"
      redirect_to post_path(@post)
    else
      flash.now[:alert] = "投稿の編集に失敗しました。"
      @large_areas = LargeArea.all
      @middle_areas = MiddleArea.all
      @genres = Genre.all
      
      if @post.restaurant_id == nil
        @restaurant = Restaurant.new
      end
      # 入力されていた都道府県とエリアコードをフォームに再セット
      @submitted_large_area_code = LargeArea.find(@large_area).large_area_code if @large_area != nil
      @submitted_middle_area_code = MiddleArea.find(@middle_area).middle_area_code if @middle_area != nil
      render :edit
    end
  end


  def destroy
    @post.destroy
    if @post.destroy
      flash[:notice] = "投稿を削除しました。"
    else
      flash[:alert] = "投稿を削除できませんでした。"
    end
    redirect_back( fallback_location: mypage_post_list_users_path )
  end
  
  
  
  private
    
    def set_post
      @post = Post.find(params[:id])
    end
    
    
    #投稿保存時のストロングパラメータを設定
    def post_params
      params.require(:post).permit( :image, :title, :genre_id, :ate, :content, :user_id, :image_cache )
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
