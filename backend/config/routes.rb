Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    post "auth/register", to: "auth#register"
    post "auth/login", to: "auth#login"
    get "me", to: "auth#me"

    resources :interns, only: %i[index show]
    patch "interns/me", to: "interns#update_me"

    resources :job_postings, only: %i[index show update destroy]
    get "companies/me/job_postings", to: "job_postings#mine"
    post "companies/me/job_postings", to: "job_postings#create"

    resources :conversations, only: %i[index create] do
      resources :messages, only: %i[index create]
      member { post :read }
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
