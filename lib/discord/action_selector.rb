class ActionSelector
  def initialize
    @actions =
      Dir
      .glob(Rails.root.join("lib", "discord", "actions", "**", "*"))
      .select { |filename| filename =~ /_action\.rb$/ }
      .map { |filename| filename.gsub(/.*\/actions\/(.+_action)\.rb/, '\1').camelize.constantize.new }
      .sort_by { |instance| [-(instance.try(:priority) || 0), instance.class.to_s] }
  end

  def execute(message_event)
    @actions.each do |action|
      return action.execute(message_event) if action.execute?(message_event)
    end
  end
end
