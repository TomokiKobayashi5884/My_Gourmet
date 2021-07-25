class Dashboard::ContactsController < ApplicationController
    before_action :authenticate_admin!
    before_action :set_contact, only: %w[show destroy]
    layout "dashboard/dashboard"
    
    # 1ページあたりの表示件数
    PER = 15
    
    def index
        contacts = Contact.search_by_keyword(params[:keyword]).search_by_name(params[:name]).search_by_email(params[:email])
        @contacts = contacts.page(params[:page]).order(created_at: :desc).per(PER)
        @total_count = contacts.count
    end
    
    def show
    end

    def destroy
        if contact.destroy
            flash[:notice] = "#{@contact.subject}を削除しました"
        else
            flash[:alert] = "#{@contact.subject}を削除できませんでした"
        end
        redirect_to dashboard_contacts_path
    end

    private
    
        def set_contact
            @contact = Contact.find(params[:id])
        end
end
