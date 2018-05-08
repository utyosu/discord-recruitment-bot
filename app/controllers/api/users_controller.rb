module Api
  class UsersController < ApplicationController

    def get_from_discord_id
      user = User.find_or_initialize_by(discord_id: params[:id])
      user.save
      render json: user
    end

    def update
      p user_params
      user = User.find(params[:id]).update(user_params)
      render json: user
    end

    private

    def user_params
      params.require(:user).permit(:flickr_at, :flickr_count, :fortune_at, :fortune_count, :nickname_at, :nickname_count, :weather_at, :weather_count)
    end
  end
end
