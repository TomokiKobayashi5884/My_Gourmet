class CommentsController < ApplicationController
    before_action :authenticate_user!
    
    def create
        post = Post.find(params[:post_id])
        @comment = post.comments.build(comment_params)
        # @comment.user_id = current_user.id
        logger.debug("======================@comment #{@comment}")
        if @comment.save
            flash[:notice] = "コメントしました"
            # redirect_to post_path(post)
            redirect_back(fallback_location: post_path(post))
        else
            flash[:alert] = "コメントできませんでした"
             @comment.errors.full_messages.each do |message|
                flash[:alert] = message
            end
            redirect_back(fallback_location: post_path(post))
        end
    end
    
    def destroy
        post = Post.find(params[:post_id])
        comment = post.comments.find(params[:id])
        comment.destroy
        if comment.destroy
            flash[:notice] = "コメントを削除しました"
            redirect_back(fallback_location: post_path(post))
        else
            flash[:alert] = "コメントを削除できませんでした"
            redirect_back(fallback_location: post_path(post))
        end
        
    end
        
    
    
    private
      
      def comment_params
          params.permit(:content).merge(user_id: current_user.id, post_id: params[:post_id])
      end
end
