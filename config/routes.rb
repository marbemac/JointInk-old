ThisThat::Application.routes.draw do

  get 'switch_user', :controller => 'switch_user', :action => 'set_current_user'

  #authenticated :user do
    #root :to => 'pages#index'
  #end

  resources :posts, :only => [:update, :destroy, :edit]
  scope 'p' do
    scope ':id' do
      get 'edit' => 'posts#edit', :as => :edit_post
      put '' => 'posts#update'
      delete '' => 'posts#destroy'
      put 'update-photo' => 'posts#update_photo', :as => :post_update_photo
      put 'remove-photo' => 'posts#remove_photo', :as => :post_remove_photo
      get 'channel' => 'posts#edit', :as => :edit_post_channel
      get '' => 'posts#show_redirect', :as => :post
    end
  end

  resources :channels
  scope 'c/:id' do
    get 'new-post' => 'posts#new', :as => :new_post
    get 'edit' => 'channels#edit', :as => :edit_channel
    scope ':post_id' do
      get '' => 'posts#show', :as => :post_via_channel
    end
    get '' => 'channels#show', :as => :channel
  end

  scope 'settings' do
    get 'social' => 'users#social_settings', :as => :user_social_settings
    get 'email' => 'users#email_settings', :as => :user_email_settings
    get '' => 'users#basic_settings', :as => :user_basic_settings
  end
  get 'about' => 'pages#about', :as => :about
  get 'faq' => 'pages#faq', :as => :faq

  mount Soulmate::Server, :at => "autocomplete"

  admin_constraint = lambda do |request|
    #request.env['warden'].authenticate? and request.env['warden'].user.role?('admin')
    true
  end
  constraints admin_constraint do
    mount Sidekiq::Web, :at => '/a/workers'
  end

  devise_for :users, :skip => [:sessions,:registrations], :controllers => {
                                                             :omniauth_callbacks => "omniauth_callbacks",
                                                             :sessions => :sessions,
                                                             :registrations => :registrations,
                                                             :confirmations => :confirmations
                                                          }
  devise_scope :user do
    get 'sign-out' => 'sessions#destroy', :as => :destroy_user_session
    get 'sign-in' => 'sessions#new', :as => :signin
    post 'sign-in' => 'sessions#create', :as => :user_session
    get 'users/sign_in' => 'sessions#create' # stupid redirect after sign in if not confirmed
    get 'sign-up' => 'registrations#new', :as => :user_registration
    post 'sign-up' => 'registrations#create'
    post 'users' => 'registrations#create', :as => :user
    put 'users' => 'registrations#update', :as => :user
  end
  get '/users/auth/:provider' => 'omniauth_callbacks#passthru'

  # Testing
  get 'testing' => 'testing#test', :as => :test

  scope 'accounts' do
    put ':id/deauth' => 'users#account_deauth', :as => :account_deauth
  end

  # Users
  scope 'users' do
    post 'update_photo' => 'users#update_cover_photo', :as => :user_update_photo
  end

  put 'add/:user_id(/:channel_id)' => 'users#add', :as => :user_add
  put 'remove/:user_id(/:channel_id)' => 'users#remove', :as => :user_remove

  get 'home' => 'pages#home', :as => :home

  get 'drafts' => 'users#drafts', :as => :user_drafts
  scope ':id' do
    scope ':channel_id' do
      get '' => 'users#show', :as => :user_channel, :page => 'posts'
    end
    put '' => 'users#update', :as => :update_user
    get '' => 'users#show', :as => :user, :page => 'posts'
  end

  root :to => "pages#home"

  unless Rails.application.config.consider_all_requests_local
    match '*not_found', to: 'errors#error_404'
  end
end