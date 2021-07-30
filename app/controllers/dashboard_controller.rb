class DashboardController < ApplicationController
    before_action :authenticate_admin!
    layout 'dashboard/dashboard'
    
    
    def index
        # データの日時を指定
        params[:date] = date_info
        @date = params[:date] ? params[:date] : Time.zone.today
        
        # 総会員数
        @user_count = User.where( created_at: @date.all_month ).count
        # 総会員数に対する食べたい物リストの作成率(%)
        if @user_count.zero?
            @creation_rate_of_list = 0.0
        else
            @creation_rate_of_list = ( ( Favorite.where( created_at: @date.all_month ).distinct.pluck(:user_id).count.to_f / @user_count.to_f ) * 100 ).round(2)
        end
        # 総投稿数
        @post_count = Post.where( created_at: @date.all_month ).count
        # 総コメント数
        @comment_count = Comment.where( created_at: @date.all_month ).count
        
        # 前月の総会員数
        last_user_count = User.where( created_at: @date.last_month.all_month ).count
        # 前月の総会員数に対する食べたい物リストの作成率(%)
        if last_user_count.zero?
            last_creation_rate_of_list = 0.0
        else
            last_creation_rate_of_list = ( ( Favorite.where( created_at: @date.last_month.all_month ).distinct.pluck(:user_id).count.to_f / last_user_count.to_f ) * 100 ).round(2)
        end
        # 前月の総投稿数
        last_post_count = Post.where( created_at: @date.last_month.all_month ).count
        # 前月の総コメント数
        last_comment_count = Comment.where( created_at: @date.last_month.all_month ).count
        
        logger.debug("-------------last_user_count #{last_user_count}")
        logger.debug("-------------last_creation_rate_of_list #{last_creation_rate_of_list}")
        logger.debug("-------------last_post_count #{last_post_count}")
        logger.debug("-------------last_comment_count #{last_comment_count}")
        logger.debug("-------------@mom_creation_rate_of_list #{@creation_rate_of_list - last_creation_rate_of_list}")
        # 前月比
        @mom_user_count = @user_count - last_user_count
        @mom_creation_rate_of_list = @creation_rate_of_list - last_creation_rate_of_list
        @mom_post_count = @post_count - last_post_count
        @mom_comment_count = @comment_count - last_comment_count
    end
    
    
    private
    
        def date_info
            if params["date(1i)"].present? && params["date(2i)"].present? && params["date(3i)"].present?
                # 年月日別々できたものを結合して新しいparams型変数を作って返す
                Date.new params["date(1i)"].to_i, params["date(2i)"].to_i, params["date(3i)"].to_i
            end
        end
end
