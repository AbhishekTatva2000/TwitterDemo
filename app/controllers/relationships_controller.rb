class RelationshipsController < ApplicationController
    before_action :set_user, only: :create

    def create
        json_response({status: false, message: "You are already following this user!"}, :bad_request) and return if current_user.following?(@tw_user)
        
        if current_user.id == @tw_user.id
            json_response({success: false, message: "You can not fllow your self!"}, :bad_request)
        else
            @Relationship = current_user.follow!(@tw_user)
            json_response(status: true, message: "Successfully followd!")
        end
    end

    def destroy
        @tw_user = Relationship.find(params[:id]).followed

        @relationship = current_user.unfollow!(@tw_user)
        json_response({ success: false, message: "Successfully unfollowed this user.", data: @relationship })
    end

    private
    def set_user
        @tw_user = User.find(params[:followed_id])
    end

end
