class AnalysisesController < ApplicationController
  # 四天王の集計期間
  KINGS_AGGREGATION_PERIOD_DAYS = 7

  # 時間帯別平均アクティブ人数の集計期間
  HOURLY_ACTIVE_AGGREGATION_PERIOD_DAYS = 7

  def index
    @start_date = Date.parse(params[:start_date]) rescue Date.today
    @end_date = Date.parse(params[:end_date]) rescue Date.today
    user_statuses = UserStatus.where(created_at: @start_date.in_time_zone..@end_date.in_time_zone.since(1.day))
    @channel_use_time_list = {}
    @user_login_time_list = {}
    user_statuses.each do |user_status|
      @channel_use_time_list[user_status.channel] = 0 if @channel_use_time_list[user_status.channel].blank?
      @channel_use_time_list[user_status.channel] += user_status.interval
      @user_login_time_list[user_status.user] = 0 if @user_login_time_list[user_status.user].blank?
      @user_login_time_list[user_status.user] += user_status.interval
    end
    @channel_use_time_list = @channel_use_time_list.to_a.sort_by { |_k, v| v }.reverse
    @user_login_time_list = @user_login_time_list.to_a.sort_by { |_k, v| v }.reverse
  end

  def records
    records = [
      { label: I18n.t('analysis.record.recruit_count'), value: "#{Recruitment.count.to_s(:delimited)} #{I18n.t('analysis.record.count_label')}" },
      { label: I18n.t('analysis.record.participant_count'), value: "#{Participant.count.to_s(:delimited)} #{I18n.t('analysis.record.count_label')}" },
      { label: I18n.t('analysis.record.calling_time'), value: "#{(UserStatus.count * Settings.analysis.interval_sec / 1.hour).to_s(:delimited)} #{I18n.t('analysis.record.time_label')}" }
    ]

    render json: { items: records, title: I18n.t('analysis.record.title') }
  end

  def kings
    king_user_ids = []
    king_user_ids << max_recruitment_user_id(king_user_ids)
    king_user_ids << max_connection_user_id(king_user_ids)

    kings = king_user_ids.compact.map { |king_user_id|
      { label: User.find(king_user_id).name }
    }

    # render json: { items: kings, title: I18n.t('analysis.king.title') }
    render json: { items: [{ label: I18n.t('analysis.king.tobe') }], title: I18n.t('analysis.king.title') }
  end

  def hourlyactive
    period_end = Time.zone.today.beginning_of_day
    period_start = period_end.ago(HOURLY_ACTIVE_AGGREGATION_PERIOD_DAYS.days)
    user_statuses = UserStatus.where(created_at: period_start..period_end)

    user_statuses_group_by_hour = user_statuses.group_by { |user_status|
      user_status.created_at.hour
    }

    hourlyactive = 24.times.map do |hour|
      active_user_count = user_statuses_group_by_hour[hour]&.count || 0
      { x: 3600 * hour, y: (active_user_count.to_f / HOURLY_ACTIVE_AGGREGATION_PERIOD_DAYS).ceil }
    end

    render json: { points: hourlyactive, displayedValue: ' ', title: I18n.t('analysis.hourlyactive.title') }
  end

  def monthlyactive
    period_end = Time.zone.today.beginning_of_day
    period_start = period_end.ago(30.days)
    active_user_count = UserStatus.where(created_at: period_start..period_end).group(:user_id).pluck(:user_id).count

    render json: { current: active_user_count, title: I18n.t('analysis.monthlyactive.title') }
  end

  private

  def max_recruitment_user_id(exclude_user_ids)
    base_time = Time.zone.today.midnight
    Recruitment.includes(:participants).where(created_at: base_time.ago(KINGS_AGGREGATION_PERIOD_DAYS.days)..base_time).map { |recruitment|
      recruitment.participants.first.user_id
    }.group_by(&:itself).each_with_object({}) { |(user_id, values), hash|
      hash[user_id] = values.count
    }.max_by { |user_id, count|
      exclude_user_ids.include?(user_id) ? 0 : count
    }&.first
  end

  def max_connection_user_id(exclude_user_ids)
    base_time = Time.zone.today.midnight
    UserStatus.where(created_at: base_time.ago(KINGS_AGGREGATION_PERIOD_DAYS.days)..base_time).map { |user_status|
      user_status.user_id
    }.group_by(&:itself).each_with_object({}) { |(user_id, values), hash|
      hash[user_id] = values.count
    }.max_by { |user_id, count|
      exclude_user_ids.include?(user_id) ? 0 : count
    }&.first
  end
end
