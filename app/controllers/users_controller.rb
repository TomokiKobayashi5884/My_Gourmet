class UsersController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!
  
  def edit
  end

  def update
    @user.update_without_password(user_params)
    redirect_to mypage_edit_users_path
  end

  def mypage
  end
  
  # 食べたい物リスト
  def my_gourmet_list
    
    favorites = Favorites.where(user_id: current_user.id).pluck(:post_id)
    @my_gourmet_list = Post.find(favorites)
  end
  
  def post_list
  end
  
  def edit_password
  end
  
  def update_password
    
    if password_set?
      @user.update_password(user_params)
      flash[:notice] = "パスワードは正常に更新されました。"
      redirect_to root_url
    else
      @user.errors.add(:password, "パスワードに不備があります。")
      render "edit_password"
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
