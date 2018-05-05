class AnalysisesController < ApplicationController
  def index
    @start_date = Date.parse(params[:start_date]) rescue Date.today
    @end_date = Date.parse(params[:end_date]) rescue Date.today
    user_statuses = UserStatus.where(created_at: @start_date.in_time_zone..(@end_date.in_time_zone+60*60*24))
    @channel_use_time_list = {}
    @user_login_time_list = {}
    user_statuses.each do |user_status|
      @channel_use_time_list[user_status.channel] = 0 if @channel_use_time_list[user_status.channel].blank?
      @channel_use_time_list[user_status.channel] += user_status.interval
      @user_login_time_list[user_status.user] = 0 if @user_login_time_list[user_status.user].blank?
      @user_login_time_list[user_status.user] += user_status.interval
    end
  end
end
