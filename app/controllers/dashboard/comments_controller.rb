class Dashboard::CommentsController < ApplicationController
    before_action :authenticate_admin!
    before_action :set_comment, only: %w[show edit update destroy]
    layout "dashboard/dashboard"
    
    def index
         # コメント検索機能
        comments = Comment.search_by_keyword(params[:keyword]).search_by_user(params[:user_id]).search_by_post(params[:post_id])
        @comments = comments.display_list(params[:page])
        @total_count = comments.count
    end
    
    def edit
    end
    
    def update
        if @comment.update(comment_params)
            flash[:notice] = "#{@comment.id}を編集しました"
            redirect_to dashboard_comments_path
        else
            flash[:alert] = "#{@comment.id}の編集に失敗しました"
            render :edit
        end
    end
    
    def destroy
        if @comment.destroy
            flash[:notice] = "#{@comment.id}を削除しました"
        else
            flash[:alert] = "#{@comment.id}を削除できませんでした"
        end
        redirect_to dashboard_comments_path
    end
    
    
    private
        
        def set_comment
            @comment = Comment.find(params[:id])
        end
        
        def comment_params
            params.require(:comment).permit(:content)
        end
            
end
