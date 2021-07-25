class Dashboard::AdminsController < ApplicationController
    before_action :authenticate_admin!
    before_action :set_contact, only: %w[show destroy]
    layout "dashboard/dashboard"
    
    def index
        admins = Admin.search_by_keyword(params[:keyword])
        @admins = admins.display_list(params[:page])
        @total_count = admins.count
    end
end
