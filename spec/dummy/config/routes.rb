Dummy::Application.routes.draw do
  get '/labs/:id' => 'application#home', as: :labs
  get '/asd/:id' => 'application#home', as: :asd
  get "home(.:format)" => "application#index"
  get '*cmspath(.:format)' => 'application#index'
end
