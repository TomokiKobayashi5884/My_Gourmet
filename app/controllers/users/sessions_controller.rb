# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  before_action :reject_user, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end
  
  def after_sign_in_path_for(user)
    posts_path
  end
  
  def after_sign_out_path_for(user)
    root_path
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:name, :email, :password, :password_confirmation])
  end
  # 退会済みのユーザーはログインできないようにする
  def reject_user
    @user = User.find_by(email: params[:user][:email].downcase)
    if @user
      if @user.deleted_flg?
        set_flash_message! :alert, :deleted
        redirect_to new_user_session_path
      end
    end
  end
end
