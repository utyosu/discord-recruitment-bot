module Api
  class UserStatusesController < ApplicationController
    def create
      user = User.find_or_initialize_by(discord_id: user_status_params[:user_discord_id])
      user.update(name: user_status_params[:user_name])

      channel = Channel.find_or_initialize_by(channel_id: user_status_params[:channel_id])
      channel.update(name: user_status_params[:channel_name])

      user_status = UserStatus.create!(user: user, channel: channel, interval: user_status_params[:interval])
      render json: user_status, status: 201
    end

    def last_updated
      user_status = UserStatus.last
      updated_at = user_status.present? ? user_status.created_at : Time.zone.now
      render json: {updated_at: updated_at}
    end

    private

    def user_create_or_update
      return user
    end

    def user_status_params
      params.require(:user_status).permit(:user_discord_id, :user_name, :channel_id, :channel_name, :interval)
    end
  end
end
