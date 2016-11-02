Dummy::Application.routes.draw do
  get '/labs/:id' => 'application#home', as: :labs
  get "home(.:format)" => "application#index"
  get '*cmspath(.:format)' => 'application#index'
end
