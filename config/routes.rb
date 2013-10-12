Cleancheese::Application.routes.draw do
  scope "api" do
    resources :tasks
  end

  root to: "main#index"
end