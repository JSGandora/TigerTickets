Rails.application.routes.draw do
  
  get 'my-tix', to: 'account#mytix'
  post 'sell', to: 'sell#sellrequest'
  post 'cancel-sell', to: 'sell#cancelsell'
  post 'buy', to: 'buy#buyrequest'
  post 'cancel-buy', to: 'buy#cancelbuy'
  get 'shows', to: 'shows_view#getshows'
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
