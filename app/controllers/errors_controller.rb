class ErrorsController < ActionController::Base
  layout 'error'

  def error_404
    @fullscreen = true
    @not_found_path = params[:not_found]
  end

  def error_500
    @fullscreen = true
  end
end