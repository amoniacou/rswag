# frozen_string_literal: true

require 'rack/auth/basic'

module Rswag
  module Ui
    # Extend Rack HTTP Basic Authentication, as per RFC 2617.
    # @api private
    #
    class BasicAuth < ::Rack::Auth::Basic
      def call(env)
        return @app.call(env) if not_rswag_basic_auth(env)

        super(env)
      end

      private

      def not_rswag_basic_auth(env)
        !env_matching_path(env) || white_ips_access(env)
      end

      def env_matching_path(env)
        path = URI.parse(env['PATH_INFO']).path.to_s
        path.match?(Rswag::Ui::Engine.routes.find_script_name({}))
      end

      def white_ips_access(env)
        white_ips.any? do |block|
          IPAddr.new(block).include?(IPAddr.new(env['action_dispatch.remote_ip'].to_s))
        end
      end

      def white_ips
        ENV.fetch('API_DOCS_WHITE_IPS', '').split(',').map(&:strip)
      end
    end
  end
end
