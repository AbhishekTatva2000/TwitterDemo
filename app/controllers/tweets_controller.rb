class TweetsController < ApplicationController
    before_action :set_user, only: :index

    def create
        @tweet = current_user.tweets.build(tweet_params)

        if @tweet.save
            json_response(@tweet, :created)
        else
            json_response({ success: false, message: "Error while creating tweet", errors: @tweet.errors }, :unprocessable_entity)
        end
    end

    def index
        if(params[:follow] == "following")
            @following_user_ids = @user.following.pluck(:id)
            @tweets = Tweet.where(user_id: @following_user_ids).order(created_at: :desc).includes(:user)
        
            json_response(@tweets)
        elsif(params[:follow] == "followers")
            @followed_user_ids = @user.followers.pluck(:id)
            @tweets = Tweet.where(user_id: @followed_user_ids).order(created_at: :desc).includes(:user)
            json_response(@tweets)
        else
            json_response({success: false, message: "Please pass appropriate parameter in follow!"}, :bad_request)
        end
    end

    def update
        @tweet = current_user.tweets.find_by(id: params[:id]).update(tweet_params)

        if @tweet
            json_response(success: true, message: "Tweet successfully edited!",tweet: tweet_params)
        else
            json_response({success: false, message: "Something went wrong!"}, :unprocessable_entity)
        end
    end

    def destroy
        @tweet = current_user.tweets.find_by(id: params[:id]).delete

        if @tweet
            json_response(success: true, message: "Tweet successfully deleted!")
        else
            json_response({success: false, message: "Something went wrong!"}, :unprocessable_entity)
        end
    end

    private
    def tweet_params
        params.require(:tweet).permit(:content)
    end

    private
    def set_user
        @user = User.find(params[:user_id])
    end

end
