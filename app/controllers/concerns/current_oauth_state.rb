# frozen_string_literal: true

module CurrentOAuthState
  extend ActiveSupport::Concern

  included do
    helper_method :oauth_state_params

    def current_oauth_state
      return @current_oauth_state if defined?(@current_oauth_state)

      osid = oauth_state_param.fetch(:osid, nil)
      @current_oauth_state = AuthorizationServer::OAuthState.find_by(id: osid)
    end
  end

  private

  def oauth_state_params
    { osid: current_oauth_state.id }
  end


  def oauth_state_param
    params.permit(:osid)
  end
end
