class FavoritesController < ApplicationController
  before_action :set_post
  before_action :authenticate_user!
  
  # 食べたい！登録（食べたい物リストに追加）
  def create
    @favorite = Favorite.create(user_id: current_user.id, post_id: @post.id)
    respond_to do |format|
      format.js { flash.now[:notice] = "#{@post.title}が食べたい物リストに追加されました" }
    end
    
  end
  
  def destroy
     @favorite = Favorite.find_by(user_id: current_user.id, post_id: @post.id)
     @favorite.destroy
     respond_to do |format|
      format.js { flash.now[:notice] = "#{@post.title}が食べたい物リストから削除されました" }
     end
  end
  
  private
  
    def set_post
      @post = Post.find(params[:post_id])
    end
end
