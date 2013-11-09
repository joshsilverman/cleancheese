Cleancheese::Application.routes.draw do
  resources :epics

  scope "api" do
    resources :tasks

    resources :users do
      collection do
        post "receive_sms"
      end
    end
  end

  root to: "main#index"

  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)
end