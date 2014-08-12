require 'mongoid'
require 'sinatra/base'
require "sinatra/namespace"
require "sinatra/flash"
require "warden"
require "sinatra-admin/auth_strategies/admin"
require "sinatra-admin/helpers/session"
require "sinatra-admin/helpers/template_lookup"

module SinatraAdmin
  class App < Sinatra::Base
    Mongoid.raise_not_found_error = false
    I18n.config.enforce_available_locales = false

    set :sessions, true
    set :views, [views]

    register Sinatra::Namespace
    register Sinatra::Flash

    helpers SinatraAdmin::SessionHelper
    helpers SinatraAdmin::TemplateLookupHelper

    use Rack::MethodOverride
    use Warden::Manager do |config|
      config.serialize_into_session(:admin){|admin| admin.id }
      config.serialize_from_session(:admin){|id| SinatraAdmin.config.admin_model.find(id) }
      config.scope_defaults :admin,
        strategies: [:admin],
        action: '/admin/unauthenticated'
      config.failure_app = SinatraAdmin::App
    end

    Warden::Manager.before_failure do |env,opts|
      env['REQUEST_METHOD'] = 'POST'
    end

    namespace '/admin' do
      before do
        unless public_routes.include?(request.path_info)
          authenticate!
        end
      end

      get '/?' do
        redirect to(SinatraAdmin.config.default_route)
      end

      get '/login/?' do
        haml 'auth/login'.to_sym, format: :html5, layout: false
      end

      post '/login/?' do
        if warden.authenticate(:admin, scope: :admin)
          redirect to(SinatraAdmin.config.default_route)
        else
          flash.now[:error] = warden.message
          haml 'auth/login'.to_sym, format: :html5, layout: false
        end
      end

      get '/logout/?' do
        warden.logout(:admin)
        flash[:success] = 'Successfully logged out'
        redirect to('/admin/login')
      end


      post '/unauthenticated/?' do
        flash[:error] = warden.message || "You must log in"
        redirect to('/admin/login')
      end
    end
  end
end
