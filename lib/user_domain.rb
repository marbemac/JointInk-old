class UserDomain
  def self.matches?(request)
    !%w(mmdebug.com jointink.com lvh.me localhost 127.0.0.1).include?(request.host) || (request.subdomain.present? && request.subdomain != "www")
  end
end