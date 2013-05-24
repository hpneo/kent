Kent::Application.routes.draw do
  devise_for :users

  resources :posts do
    member do
      post 'mark_as_read'
      post 'mark_as_unread'
    end
  end

  resources :feeds do
    collection do
      get 'import'
      post 'import_subscriptions'
    end

    member do
      post 'import_posts'
      post 'mark_all_as_read'
    end
  end

  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/auth/failure', :to => 'sessions#failure'
  
  root :to => 'home#index'
end
