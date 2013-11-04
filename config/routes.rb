Cleancheese::Application.routes.draw do
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