Rails.application.routes.draw do
  resources :projects do
    resources :comments
    resources :project_revisions, path: 'revisions' do
      collection do
        get 'compare/:project_revision_id1' => 'project_revisions#compare'
        get 'compare/:project_revision_id1/:project_revision_id2' => 'project_revisions#compare'
      end
    end
    member do
      get 'vote'
    end
  end

  resources :users do
    collection do
      get 'login'
      post 'create'
      post 'post_login'
      get 'logout'
      get 'reset_password_form'
      post 'post_reset_password_form'
    end
    member do
      get 'validate_confirmation'
      post 'set_password_and_info'
      get 'confirmation_sent'
      get 'validate_reset_password'
      get 'edit_password'
      get 'reset_password'
      post 'post_reset_password'
      patch 'update_password'
      get 'resend_confirmation'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'users/login'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
