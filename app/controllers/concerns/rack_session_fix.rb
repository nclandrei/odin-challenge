# Creates a fake session to satisfy Devise's session requirement when using JWT.
# Open GitHub issue tracking this bug: https://github.com/waiting-for-dev/devise-jwt/issues/235
module RackSessionFix
  extend ActiveSupport::Concern

  class RackSession < Hash
    def enabled?
      false
    end
  end

  included do
    before_action :set_rack_session

    private

    def set_rack_session
      request.env["rack.session"] ||= RackSession.new
    end
  end
end
