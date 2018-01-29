Sinicum::Engine.routes.draw do
  defaults format: :json do
    delete "cache" => "cache#delete"
  end
end
