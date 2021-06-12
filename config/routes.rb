Rails.application.routes.draw do
 
  devise_for :users, :controllers => {
   :registrations => "users/registrations",
   :sessions => "users/sessions",
   :passwords => "users/passwords",
   :confirmations => "users/confirmations",
   :unlocks => "users/unlocks",
  }
  
  devise_scope :user do
   root to: "users/sessions#new"
   get "signup", :to => "users/registrations#new"
   get "verify", :to => "users/registrations#verify"
   get "login", :to => "users/sessions#new"
   get "logout", :to => "users/sessions#destroy"
  end
  
 resources :posts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
