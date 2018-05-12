module Api
  class UsersController < ApplicationController

    def get_from_discord_id
      user = User.find_or_initialize_by(discord_id: params[:id])
      user.save
      render json: user
    end

    def update
      user = User.find(params[:id]).update(user_params)
      render json: user
    end

    private

    def user_params
      params.require(:user).permit(:play_at, :play_count)
    end
  end
end
