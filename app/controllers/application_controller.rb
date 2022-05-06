class ApplicationController < ActionController::API
    include Response
    include ExceptionHandler

    before_action :authenticate_with_token!

    respond_to :json

    private 
    def current_user
        token = request.headers['Authorization'].presence
        @current_user ||= User.find_by_auth_token(token) if token 
    end

    def authenticate_with_token!
        json_response({success: false, message: "Authentication failed!"}, :unauthorized) unless current_user.present?
    end
end
