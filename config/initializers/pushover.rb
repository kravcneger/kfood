if Rails.env.production?
	  Pushover.configure do |config|
    #  config.user='USER_TOKEN'
    config.token='aCnwgz9GMeQNsV2iBend7x8j7DiXgD'
  end
end