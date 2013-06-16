class UserDomain
  def self.matches?(request)
    (request.host != 'jointink.com' && request.host != 'lvh.me') || (request.subdomain.present? && request.subdomain != "www")
  end
end