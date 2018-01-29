module Sinicum
  class CacheController < ActionController::Base
    before_action :check_authentication

    def delete
      cache = Sinicum::Jcr::Cache::GlobalCache.new
      cache.reset_key(params[:namespace])
      render json: { message: "OK" }
    end

    private

    def check_authentication
      unless authenticated?
        render json: { message: "Not authenticated" }, status: :unauthorized
      end
    end

    def authenticated?
      auth_key = Rails.configuration.x.sinicum && Rails.configuration.x.sinicum.admin_auth_key
      auth_key && request.headers["HTTP_AUTH"] == auth_key
    end
  end
end
