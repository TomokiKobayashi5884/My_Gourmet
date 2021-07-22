class Dashboard::UsersController < ApplicationController
    before_action :authenticate_admin!
    layout "dashboard/dashboard"
    
    def index
        users = User.search_by_keyword(params[:keyword])
        @users = users.display_list(params[:page])
        @total_count = users.count
    end
    
    def destroy
        # ユーザーを論理削除
        user = User.find(params[:id])
        deleted_flg = User.switch_flg(user.deleted_flg)
        user.update(deleted_flg: deleted_flg)
        redirect_to dashboard_users_path
    end
end
