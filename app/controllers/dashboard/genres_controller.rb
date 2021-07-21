class Dashboard::GenresController < ApplicationController
    before_action :authenticate_admin!, except: :index
    before_action :set_genres, only: %w[show edit update destroy]
    layout "dashboard/dashboard"
    
    
    def index
        # 中エリア検索機能
        genres = Genre.search_by_keyword(params[:keyword])
        @genres = genres.display_list(params[:page])
        @total_count = genres.count
    end
    
    def new
        @genre = Genre.new
    end
    
    def create
       @genre = Genre.new(genre_params)
       if @genre.save
           flash[:notice] = "#{@genre.name}を新規作成しました"
           redirect_to dashboard_genres_path
       else
           flash.now[:alert] = "新規作成に失敗しました"
           render :new
       end
    end
    
    def edit
        @large_areas = Genre.all
    end
    
    def update
        if @genre.update(genre_params)
            flash[:notice] = "#{@genre.name}を編集しました"
            redirect_to dashboard_genres_path
        else
            flash.now[:alert] = "#{@genre.name}の編集に失敗しました"
            render :edit
        end
    end
    
    def destroy
        if @genre.destroy
            flash[:notice] = "#{@genre.name}を削除しました"
        else
            flash[:alert] = "#{@genre.name}を削除できませんでした"
        end
        redirect_to dashboard_genres_path
    end
    
    
    private
    
        def set_genres
            @genre = Genre.find(params[:id])
        end
        
        def genre_params
            params.require(:genre).permit(:name, :genre_code)
        end
end
