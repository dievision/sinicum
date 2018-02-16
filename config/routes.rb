Sinicum::Engine.routes.draw do
  defaults format: :json do
    delete "cache" => "sinicum/cache#delete"
  end
end
