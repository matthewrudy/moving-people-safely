Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  resource :session, only: %i[ new destroy ]

  get :ping, to: 'ping#show'

  resource :court, only: %i[show] do
    get :select
    post :change
  end

  resources :escorts, only: %i[show new create] do
    get :confirm_cancel, on: :member
    put :cancel, on: :member
    resource :detainee do
      resource :image, only: %i[show], controller: 'detainees/images', constraints: { format: 'jpg' }
    end
    resource :move
    resource :healthcare, except: :destroy do
      get :intro, on: :collection
      put :confirm, on: :collection
    end
    resource :risks, except: :destroy, path: 'risk' do
      put :confirm, on: :collection
    end
    resource :offences, only: %i[show update]
    resource :print, only: %i[new show], controller: 'escorts/print'
  end

  resources :feedbacks, only: %i[new create]
  post '/detainees/search', to: 'homepage#detainees'
  post '/escorts/search', to: 'homepage#escorts'
  root to: 'homepage#show'
end
