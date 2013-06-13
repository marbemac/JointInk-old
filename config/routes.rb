JointInk::Application.routes.draw do

  get 'health_check' => 'pages#health_check'
  get 'active_user/posts/:id.js' => 'posts#active_user', :as => :active_user_post_js
  get 'active_user.js' => 'users#active_user', :as => :active_user_js

  # incoming emails
  scope 'emails' do
    post '' => 'emails#post'
  end

  # stats
  scope 'stats' do
    post '' => 'stats#create', :as => :stat
  end

  # posts
  scope 'p' do
    get 'new-:type-:subtype-post' => 'posts#new', :as => :new_post
    scope ':id' do
      get 'edit' => 'posts#edit', :as => :edit_post
      get 'stats' => 'posts#stats', :as => :post_stats
      put '' => 'posts#update'
      delete '' => 'posts#destroy'

      post 'update-photo' => 'posts#update_photo', :as => :post_update_photo
      put 'remove-photo' => 'posts#remove_photo', :as => :post_remove_photo

      post 'add-inline-photo' => 'posts#add_inline_photo', :as => :post_add_inline_photo

      put 'update-audio' => 'posts#update_audio', :as => :post_update_audio
      put 'remove-audio' => 'posts#remove_audio', :as => :post_remove_audio

      get '' => 'posts#show_redirect', :as => :post

      scope 'vote' do
        put '' => 'posts#create_vote', :as => :post_vote
        delete '' => 'posts#destroy_vote', :as => :post_vote
      end

      scope 'channels' do
        get '' => 'posts#channels', :as => :post_channels
        put '' => 'posts#add_channel', :as => :post_add_channel
        delete '' => 'posts#remove_channel', :as => :post_remove_channel
      end
    end
  end

  # search
  scope 'search' do
    get ':resource' => 'search#go', :resource => 'all'
  end

  # pages
  get 'about' => 'pages#about', :as => :about
  get 'faq' => 'pages#faq', :as => :faq

  #admin_constraint = lambda do |request|
    #request.env['warden'].authenticate? and request.env['warden'].user.role?('admin')
    #true
  #end
  #constraints admin_constraint do
    #mount Sidekiq::Web, :at => '/a/workers'
  #end

  # users
  scope 'u' do
    get 'check_username' => 'users#check_username', :as => :check_username

    scope '/:id' do
      get '' => 'users#show_redirect', :as => :user_permalink
    end
  end
  devise_for :users, :skip => [:sessions,:registrations], :controllers => {
                                                             :omniauth_callbacks => "omniauth_callbacks",
                                                             :sessions => :sessions,
                                                             :registrations => :registrations,
                                                             :confirmations => :confirmations
                                                          }
  devise_scope :user do
    get 'sign-out' => 'sessions#destroy', :as => :destroy_user_session
    get 'sign-in' => 'sessions#new', :as => :user_session
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

  #scope 'accounts' do
  #  put ':id/deauth' => 'users#account_deauth', :as => :account_deauth
  #end

  get 'home' => 'pages#home', :as => :home
  get 'settings' => 'users#settings', :as => :settings
  get 'recommendations' => 'users#recommendations', :as => :user_recommendations
  get 'dashboard' => 'users#dashboard', :as => :user_dashboard
  get 'feed' => 'users#show', :as => :user_feed

  # Users
  scope 'users' do
    put 'update_avatar' => 'users#update_avatar', :as => :update_user_avatar
  end

  put 'add/:user_id(/:channel_id)' => 'users#add', :as => :user_add
  put 'remove/:user_id(/:channel_id)' => 'users#remove', :as => :user_remove

  constraints(Subdomain) do
    get '' => 'users#show', :as => :user
    put '' => 'users#update', :as => :update_user
    get 'channels' => 'users#channels', :as => :user_channels
  end

  # channels
  resources :channels
  scope ':id' do
    get 'feed' => 'channels#show', :as => :channel_feed
    get 'edit' => 'channels#edit', :as => :edit_channel
    get 'members' => 'channels#members', :as => :channel_members
    get 'new-:type-:subtype-post' => 'posts#new', :as => :new_channel_post
    put '' => 'channels#update'
    scope ':post_id(/:title)' do
      get '' => 'posts#show', :as => :post_via_channel
    end
    get '' => 'channels#show', :as => :channel
  end

  root :to => "pages#home"

  unless Rails.application.config.consider_all_requests_local
    match '*not_found', to: 'errors#error_404'
  end
end