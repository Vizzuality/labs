module ApplicationHelper
  def gravatar user
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=60"
  end

  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
              concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
              concat message
            end)
    end
    nil
  end

  def fa_icon_in_span(icon_name, sr_msg, msg=nil)
    content_tag(:span, " #{msg} ",
      {class: "fa fa-#{icon_name}", 'aria-hidden' => true}
    ) +
    content_tag(:span, sr_msg, class: 'sr-only')
  end
end
