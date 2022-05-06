# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  skip_before_action :authenticate_with_token!, only: :create
	skip_before_action :verify_signed_out_user, only: :destroy
	before_action :user_params_exists, only: :create

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    @resource = User.find_for_database_authentication(email: params[:user][:email])
    return invalid_login_attempt unless @resource
    if @resource.valid_password?(params[:user][:password])
      sign_in @resource, store: false
      @resource.generate_auth_token!
      @resource.save
      json_response({success: true, message: "Login Successful", data: {id: @resource.id , email: @resource.email, auth_token: @resource.auth_token}} )
    else
      invalid_login_attempt
    end
  end

  # DELETE /resource/sign_out
  def destroy
    sign_out(current_user)
    current_user.update(auth_token: nil)
    json_response({success: true, message: "successfully Logout!"})
  end

  private 
    def invalid_login_attempt
      json_response({success: false, message: "Username/Password is wrong!"}, 400)
    end

    def user_params_exists
      return unless params[:user].blank?
      json_response({success: false, message: "Missing parameters!"}, :unprocessable_entity)
    end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
