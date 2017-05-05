Rails.application.routes.draw do
  resources :answers do
    resources :upvotes
  end
  resources :questions

  root :to => 'questions#index'
end
