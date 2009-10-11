ActionController::Routing::Routes.draw do |map|
  map.resources :excs, :only => [:create]
end