class UsersController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!
  
  # 1ページあたりの表示件数
  PER = 10
  
  
  def edit
  end

  def update
    if @user.update_without_password(user_params)
      redirect_to mypage_edit_users_path
      logger.debug("^^^^^^^^^^^^^^^^^^user update")
    else
      logger.debug("^^^^^^^^^^^^^^^^^^user not update")
      render :edit
    end
  end

  def mypage
  end
  
  # 食べたい物リスト
  def my_gourmet_list
    @large_areas = LargeArea.all
    @middle_areas = MiddleArea.all
    @genres = Genre.all
    
    favorite_post_ids = Favorite.where(user_id: @user.id).pluck(:post_id)
    logger.debug("~~~~~~~~~~~~~~~~~~~~~~~~~favorite_post_ids #{favorite_post_ids}")
    favorites_posts = Post.where(id: favorite_post_ids)
    # -----------------------------------リスト内検索処理------------------------------------------
    logger.debug("---------------------------params[:large_area_id] #{params[:large_area_id]}")
   
    logger.debug("---------------------------params[:genre_id] #{params[:genre_id]}")
    logger.debug("---------------------------params[:keyword] #{params[:keyword]}")
    if params[:large_area_id].present?
      restaurant_id = Restaurant.where(large_area_id: params[:large_area_id]).pluck(:id)
      post_large_area = favorites_posts.where(restaurant_id: restaurant_id).pluck(:id)
      
      if params[:post][:middle_area_id].present?
         logger.debug("---------------------------params[:post][:middle_area_id] #{params[:post][:middle_area_id]}")
        restaurant_id = Restaurant.where(middle_area_id: params[:post][:middle_area_id]).pluck(:id)
        post_middle_area = favorites_posts.where(restaurant_id: restaurant_id).pluck(:id)
      else
        post_middle_area = favorites_posts.all.pluck(:id)
      end
    else
      post_large_area = favorites_posts.all.pluck(:id)
      post_middle_area = favorites_posts.all.pluck(:id)
    end
    
    if params[:genre_id].present?
      post_genre = favorites_posts.where(genre_id: params[:genre_id]).pluck(:id)
    else
      post_genre = favorites_posts.all.pluck(:id)
    end
    
    if params[:keyword].present?
      @hit_posts = favorites_posts.search_by_keyword(params[:keyword].strip).where(" id IN (?) and id IN (?) and id IN (?)", post_large_area, post_middle_area, post_genre)
                   .order("updated_at DESC")
      @posts = @hit_posts.page(params[:page]).per(PER)
    else
      @hit_posts = favorites_posts.where(" id IN (?) and id IN (?) and id IN (?)", post_large_area, post_middle_area, post_genre)
                   .order("updated_at DESC")
      @posts = @hit_posts.page(params[:page]).per(PER)
    end
  end
  
  # 過去の投稿一覧
  def post_list
    @posts = Post.where(user_id: @user.id).order("created_at DESC").page(params[:page]).per(PER)
  end
  
  def edit_password
  end
  
  def update_password
    if password_set?
      if @user.update_password(user_params)
        flash[:notice] = "パスワードは正常に更新されました。"
        redirect_to root_url
      else
        render :edit_password
      end
    else
      @user.errors.add(:password, "新しいパスワードを入力してください。")
      render :edit_password
    end
  end
  
  def destroy
    deleted_flg = User.switch_flg(@user.deleted_flg)
    if @user.update(deleted_flg: deleted_flg)
      reset_session
      flash[:notice] = "退会しました"
      redirect_to root_path
    else
      flash[:alert] = "退会できませんでした"
      redirect_to mypage_edit_users_path
    end
  end
  
  
  private
    
    def set_user
      @user = current_user
    end
    
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    def password_set?
      user_params[:password].present? && user_params[:password_confirmation].present? ? true : false
    end
end
