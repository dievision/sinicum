Dummy::Application.routes.draw do
  mount Sinicum::Engine => "/_sinicum"
  get "home(.:format)" => "application#index"
  get '*cmspath(.:format)' => 'application#index'
end
