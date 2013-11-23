Cleancheese::Application.routes.draw do
  resources :epics

  scope "api" do
    resources :tasks
    resources :epics

    resources :users do
      collection do
        post "receive_sms"
      end
    end
  end

  root to: "main#splash"

  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)
end