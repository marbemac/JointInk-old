class UserDomain
  def self.matches?(request)
    !%w(mmdebug.com jointink.com lvh.me localhost).include?(request.host) || (request.subdomain.present? && request.subdomain != "www")
  end
end