# frozen_string_literal: true

# frozen_string_litreal: true

require 'pundit'

# ApiBlocks::Controller provides a set of default configurations for
# Ruby on Rails api controllers.
#
# It sets up `ApiBlocks::Responder` as a responder, `Pundit` and controller
# defaults.
#
# @example
#
#   class Api::V1::ApplicationController < ActionController::API
#     include ApiBlocks::Controller
#
#     pundit_scope :api, :v1
#   end
#
module ApiBlocks::Controller
  extend ActiveSupport::Concern

  included do
    self.responder = ApiBlocks::Responder

    before_action :verify_request_format!

    include Pundit
    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden_error

    # Enable pundit after_action hooks to ensure policies are consistently
    # used.
    after_action :verify_authorized
    after_action :verify_policy_scoped, except: :create

    # Override policy_scope to lookup pundit policies under the `scope`
    # namespace
    def policy_scope(scope)
      super(self.class.pundit_api_scope + [scope])
    end

    # Override authorize to lookup pundit policies under the `scope`
    # namespace
    def authorize(record, query = nil)
      super(self.class.pundit_api_scope + [record], query)
    end
  end

  class_methods do
    # Provide a default scope to pundit's `PolicyFinder`.
    def pundit_scope(*scope)
      @pundit_api_scope = scope
    end

    # Returns the scope for pundit's `PolicyFinder`.
    def pundit_api_scope
      @pundit_api_scope || []
    end
  end
end
