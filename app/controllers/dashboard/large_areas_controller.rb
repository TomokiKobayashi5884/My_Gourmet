class Dashboard::LargeAreasController < ApplicationController
    before_action :authenticate_admin!, except: :index
    before_action :set_large_areas, only: %w[show edit update destroy]
    layout "dashboard/dashboard"
    
    
    def index
        if params[:keyword].present?
            keyword = params[:keyword].strip
            large_areas = LargeArea.search_by_keyword(keyword)
            @large_areas = large_areas.display_list(params[:page])
            logger.debug("----------------------@large_areas #{@large_areas.inspect}")
        else
            large_areas = LargeArea.all
            @large_areas = large_areas.display_list(params[:page])
        end
        @total_count = large_areas.count
    end
    
    def new
        @large_area = LargeArea.new
    end
    
    def create
       @large_area = LargeArea.new(large_area_params)
       if @large_area.save
           flash[:notice] = "#{@large_area.name}を新規作成しました"
           redirect_to dashboard_large_areas_path
       else
           flash.now[:alert] = "新規作成に失敗しました"
           render :new
       end
    end
    
    def edit
    end
    
    def update
        if @large_area.update(large_area_params)
            flash[:notice] = "#{@large_area.name}を編集しました"
            redirect_to dashboard_large_areas_path
        else
            flash.now[:alert] = "#{@large_area.name}の編集に失敗しました"
            render :edit
        end
    end
    
    def destroy
        if @large_area.destroy
            flash[:notice] = "#{@large_area.name}を削除しました"
        else
            flash[:alert] = "#{@large_area.name}を削除できませんでした"
        end
        redirect_to dashboard_large_areas_path
    end
    
    
    private
    
        def set_large_areas
            @large_area = LargeArea.find(params[:id])
        end
        
        def large_area_params
            params.require(:large_area).permit(:name, :large_area_code)
        end
end
