Dummy::Application.routes.draw do
  get "home(.:format)" => "application#index"
  get '*cmspath(.:format)' => 'application#index'
end
