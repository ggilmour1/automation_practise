
module GeneralUtils

  def human_friendly_timestamp
    return "#{Time.now.utc.iso8601.gsub("'", '').gsub(':', '')}"
  end

end