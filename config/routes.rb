ActionController::Routing::Routes.draw do |map|
  map.resources :custom_columns, :collection => {:choose => :get}
end
