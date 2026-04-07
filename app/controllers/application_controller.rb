class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  allow_browser versions: :modern
  stale_when_importmap_changes

  # Pundit: Rescue from unauthorized access
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
