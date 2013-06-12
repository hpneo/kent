Kent::Application.routes.draw do
  resources :users do
    collection do
      get 'token'
    end
  end
  
  devise_for :users do
    get 'sign_in' => 'devise/sessions#new', :as => :new_user_session
    get 'sign_out' => "devise/sessions#destroy", :as => :destroy_user_session
  end

  resources :posts do
    member do
      post 'mark_as_read'
      post 'mark_as_unread'
    end

    collection do
      post 'mark_all_as_read'
    end
  end

  resources :feeds do
    collection do
      get 'import'
      post 'import_subscriptions'
      post 'refresh'
    end

    member do
      post 'import_posts'
      post 'mark_all_as_read'

      get 'posts'
    end
  end

  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/auth/failure', :to => 'sessions#failure'
  
  root :to => 'home#index'
end
