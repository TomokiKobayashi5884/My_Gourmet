class DashboardController < ApplicationController
    before_action :authenticate_admin!
    layout 'dashboard/dashboard'
    
    
    def index
        # データの日時を指定
        params[:date] = date_info
        @date = params[:date] ? params[:date] : Time.zone.today
        
        # 指定した月までの総会員数
        @user_count = User.where( created_at: Date.new(2021,1,1)..@date.end_of_month ).count
        # 指定した月までの総会員数に対する食べたい物リストの作成率(%)
        if @user_count.zero?
            @creation_rate_of_list = 0.0
        else
            @creation_rate_of_list = ( ( Favorite.where( created_at: Date.new(2021,1,1)..@date.end_of_month ).distinct.pluck(:user_id).count.to_f / @user_count.to_f ) * 100 ).round(2)
        end
        # 指定した月までの総投稿数
        @post_count = Post.where( created_at: Date.new(2021,1,1)..@date.end_of_month ).count
        # 指定した月までの総コメント数
        @comment_count = Comment.where( created_at: Date.new(2021,1,1)..@date.end_of_month ).count
        
        logger.debug("-----------------------@user_count #{@user_count}")
        logger.debug("-----------------------@creation_rate_of_list #{@creation_rate_of_list}")
        logger.debug("-----------------------@post_count #{@post_count}")
        logger.debug("-----------------------@comment_count #{@comment_count}")
        
        # 前月比データ
        @mom_user_count = User.where( created_at: @date.all_month ).count
        last_user_count = User.where( created_at: Date.new(2021,1,1)..@date.last_month.end_of_month ).count
        if last_user_count.zero?
            last_creation_rate_of_list = 0.0
        else
            last_creation_rate_of_list = ( ( Favorite.where( created_at: Date.new(2021,1,1)..@date.last_month.end_of_month ).distinct.pluck(:user_id).count.to_f / last_user_count.to_f ) * 100 ).round(2)
        end
        @mom_creation_rate_of_list = @creation_rate_of_list - last_creation_rate_of_list
        @mom_post_count = Post.where( created_at: @date.all_month ).count
        @mom_comment_count = Comment.where( created_at: @date.all_month ).count
    end
    
    private
    
        def date_info
            if params["date(1i)"].present? && params["date(2i)"].present? && params["date(3i)"].present?
                # 年月日別々できたものを結合して新しいparams型変数を作って返す
                Date.new params["date(1i)"].to_i, params["date(2i)"].to_i, params["date(3i)"].to_i
            end
        end
end
