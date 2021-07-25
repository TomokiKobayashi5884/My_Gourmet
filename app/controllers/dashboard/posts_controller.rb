class Dashboard::PostsController < ApplicationController
    before_action :authenticate_admin!
    before_action :set_post, only: %w[show edit update destroy]
    layout "dashboard/dashboard"
    
    def index
      @genres = Genre.all
        posts = Post.search_by_keyword(params[:keyword]).search_by_user(params[:user_info])
                .search_by_genre(params[:genre_id]).search_by_restaurant(params[:restaurant_id])
        @posts = posts.display_list(params[:page])
        @total_count = posts.count
    end
    
    def show
        @user_name = User.find(@post.user_id).name
        @comment_count = Comment.where(post_id: @post.id).count
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
              @favorite = Favorite.create( user_id: @post.user_id, post_id: @post.id )
            else
              @favorite = Favorite.find_by( user_id: @post.user_id, post_id: @post.id )
              if @favorite.present?
                @favorite.destroy
              end
              
            end
          end
        end
        
        if redirect_flag
          flash[:notice] = "投稿を編集しました。"
          redirect_to dashboard_posts_path
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
        if @post.destroy
            flash[:notice] = "#{@post.title}を削除しました"
        else
            flash[:alert] = "#{@post.title}を削除できませんでした"
        end
        redirect_to dashboard_posts_path
    end
    
    
    private
    
        def set_post
            @post = Post.find(params[:id])
        end
        
        def post_params
            params.require(:post).permit(:title, :content, :ate, :image, :genre_id, :restaurant_id)
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
