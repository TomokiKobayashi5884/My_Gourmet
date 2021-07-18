class ApplicationController < ActionController::Base
    # before_action :configure_permitted_parameters, if: :devise_controller?
    
    protected
        # ユーザー登録時の利用規約同意用
        # def configure_permitted_parameters
        #     devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :agreement_terms)}
        # end
  
end
