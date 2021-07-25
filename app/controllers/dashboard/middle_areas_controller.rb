class Dashboard::MiddleAreasController < ApplicationController
    before_action :authenticate_admin!
    before_action :set_middle_area, only: %w[edit update destroy]
    layout "dashboard/dashboard"
    
    
    def index
        @large_aeas = LargeArea.all
        
        # 中エリア検索機能
        middle_areas = MiddleArea.search_by_keyword(params[:keyword]).search_by_large_area(params[:large_area_id])
        @middle_areas = middle_areas.display_list(params[:page])
        @total_count = middle_areas.count
    end
    
    def new
        @middle_area = MiddleArea.new
        @large_areas = LargeArea.all
    end
    
    def create
       @middle_area = MiddleArea.new(middle_area_params)
       if @middle_area.save
           flash[:notice] = "#{@middle_area.name}を新規作成しました"
           redirect_to dashboard_middle_areas_path
       else
           flash.now[:alert] = "新規作成に失敗しました"
           @large_areas = LargeArea.all
           render :new
       end
    end
    
    def edit
        @large_areas = LargeArea.all
    end
    
    def update
        if @middle_area.update(middle_area_params)
            flash[:notice] = "#{@middle_area.name}を編集しました"
            redirect_to dashboard_middle_areas_path
        else
            flash.now[:alert] = "#{@middle_area.name}の編集に失敗しました"
            @large_areas = LargeArea.all
            render :edit
        end
    end
    
    def destroy
        if @middle_area.destroy
            flash[:notice] = "#{@middle_area.name}を削除しました"
        else
            flash[:alert] = "#{@middle_area.name}を削除できませんでした"
        end
        redirect_to dashboard_middle_areas_path
    end
    
    
    private
    
        def set_middle_area
            @middle_area = MiddleArea.find(params[:id])
        end
        
        def middle_area_params
            params.require(:middle_area).permit(:name, :middle_area_code, :large_area_id)
        end
end
