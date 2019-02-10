namespace :etc do
	desc "etc"
	task :login_user_average => :environment do
		date_count = 30
		date = Time.zone.today.yesterday
		user_count_list = []
		date_count.times do
			start_date = date.beginning_of_day
			end_date = date.end_of_day
			user_statuses = UserStatus.where(created_at: start_date..end_date)
			user_count = user_statuses.map{|a|a.user_id}.sort.uniq.count
			user_count_list.push(user_count)
			date = date.yesterday
		end
		user_count_average = user_count_list.sum.to_f/date_count
		puts "list: #{user_count_list.join(",")}"
		puts "#{date_count} days user count average: #{user_count_average}"
	end
end
