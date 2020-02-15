module Helper
  module_function

  def to_safe(str)
    # <@\d+> is discord mention
    str.tr("０-９ａ-ｚＡ-Ｚ＠？：", "0-9a-zA-Z@?:").gsub(/<@\d+>/, "").gsub(/[[:blank:]]/, " ")
  end

  def get_message_content(message_event)
    message_event.content.gsub(/\r\n|\r|\n/, "")
  end
end
