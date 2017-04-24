Rails.application.routes.draw do
  # Display my tickets
  get 'my-tix-data', to: 'account#mytix'
  
  # Sell request API
  post 'sell', to: 'sell#sellrequest'
  post 'cancel-sell', to: 'sell#deletesell'
  
  # Buy request API
  post 'buy', to: 'buy#buyrequest'
  post 'cancel-buy', to: 'buy#deletebuy'
  
  # Shows API
  get 'shows', to: 'shows_view#getshows'
  
  # Front page
  get 'calendar', to: 'welcome#calendar'
  post 'logout', to: 'welcome#logout'
  get 'login', to: 'welcome#login'
  get 'my-tix', to: 'welcome#mytix'
  
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
