Rails.application.routes.draw do
  get 'my-tix-data', to: 'account#mytix'
  get 'my-tix', to: 'welcome#mytix'
  post 'sell', to: 'sell#sellrequest'
  post 'cancel-sell', to: 'sell#cancelsell'
  post 'buy', to: 'buy#buyrequest'
  post 'cancel-buy', to: 'buy#cancelbuy'
  get 'shows', to: 'shows_view#getshows'
  get 'calendar', to: 'welcome#calendar'
  post 'logout', to: 'welcome#logout'
  get 'login', to: 'welcome#login'
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
