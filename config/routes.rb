Rails.application.routes.draw do
  post 'buy', to: 'buy#buyrequest'
  post 'cancel-buy', to: 'buy#cancelbuy'
  get 'shows', to: 'shows_view#getshows'
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
