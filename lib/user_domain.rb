class UserDomain
  def self.matches?(request)
    request.host != 'jointink.com' || (request.subdomain.present? && request.subdomain != "www")
  end
end