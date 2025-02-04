Rails.application.routes.draw do
  devise_for :users,
    controllers: {
      registrations: "authentication/registrations",
      sessions: "authentication/sessions"
    },
    defaults: { format: :json }

  resource :user, only: [ :show ]

  post "/auth/refresh_token", to: "authentication/refresh_tokens#create"
end
