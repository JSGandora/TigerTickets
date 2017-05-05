Rails.application.routes.draw do
  # Display my tickets
  get 'my-tix-data', to: 'account#mytix'
  
  # Sell request API
  post 'sell', to: 'sell#sellrequest'
  post 'cancel-sell', to: 'sell#deletesell'
  post 'complete-sell', to: 'sell#complete_sell'
  post 'complete-sell-token', to: 'sell#complete_sell_token'
  
  # Buy request API
  post 'buy', to: 'buy#buyrequest'
  post 'cancel-buy', to: 'buy#deletebuy'
  post 'complete-buy', to: 'buy#complete_buy'
  post 'complete-buy-token', to: 'buy#complete_buy_token'
  
  # Shows API
  get 'shows', to: 'shows_view#getshows'

  # FAQ Page
  get 'faq', to: 'welcome#faq'

  post 'feedback', to: 'feedback#feedback_email'

  post 'logout', to: 'welcome#logout'
  get 'login', to: 'welcome#login'
  get 'my-tix', to: 'welcome#mytix'
  
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
