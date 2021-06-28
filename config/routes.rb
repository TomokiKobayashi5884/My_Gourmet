Rails.application.routes.draw do
 
  get 'favorites/create'
  get 'favorites/destroy'
  devise_for :users, :controllers => {
   :registrations => "users/registrations",
   :sessions => "users/sessions",
   :passwords => "users/passwords",
   :confirmations => "users/confirmations",
   :unlocks => "users/unlocks",
  }
  
  devise_scope :user do
   get "signup", :to => "users/registrations#new"
   get "verify", :to => "users/registrations#verify"
   get "login", :to => "users/sessions#new"
   get "logout", :to => "users/sessions#destroy"
  end
  
  resources :users, only: [:show, :edit, :update] do
   collection do
    get "mypage", :to => "users#mypage"
    put "mypage/edit", :to => "users#update"
    get "mypage/edit", :to => "users#edit"
    get "mypage/my_gourmet_list", :to => "users#my_gourmet_list"
    get "mypage/post_list", :to => "users#post_list"
    
    get "mypage/edit_password", :to => "users#edit_password"
    put "mypage/password", :to => "users#update_password"
    
    get "favorites"
   end
  end
  
  root to: "posts#index"
  post 'posts/new' => 'posts#new'
  resources :posts do
   resources :comments, only: [:create, :destroy]
   resource :favorites, only: [:create, :destroy]
   collection do
    
    # patch "new", :to => "posts#search_by_hotpepper"
    # get "middle_area_select"
   end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
