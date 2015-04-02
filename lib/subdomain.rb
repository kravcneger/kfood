class Subdomain
  def self.matches?(request)
    request.subdomain.present? && request.subdomain == "m"
  end
end