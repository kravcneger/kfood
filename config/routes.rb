Kfood::Application.routes.draw do  
  resources :categories do
    post :get_brothers , on: :collection
    get :load_menu , on: :collection    
  end

  resources :additions do
    get 'index', on: :member
  end

  resources :products do
    post :destroy_image , on: :collection
    get :additions
    get :search, on: :collection
  end

  resources :schedules do
    get :edit , on: :collection    
  end
  post '/schedules/set_holiday', to: 'schedules#set_holiday' , as: 'set_holiday'
  post '/schedules/set_around', to: 'schedules#set_around' , as: 'set_around'

  scope '/admin' do      
    resources :orders, only: [:index, :show, :destroy, :update], controller: :admin_orders do
      get :statistics, on: :collection 
    end    
  end
  get 'admin', to: 'admin_orders#index'


  devise_for :organizations, skip: [:registrations, :confirmations, :passwords]
  get 'organizations/:id/edit/:type', to: 'organizations#edit' , as: 'edit_organization'
  resources :organizations, only: [:show, :update], :path => '/' do
    resources :basket, only: [] do      
      post :remove_product, :add_product, :remove_addition, :clear, :set_number_product, on: :collection
      get :show, on: :collection
    end

    resource :orders, only: [] do
      post :create, on: :collection
      get :show, on: :collection
    end
  end  
  
  get '/:id/info', to: 'organizations#info' , as: 'info_organization'
  get 'organizations/:id/destroy_map', to: 'organizations#destroy_map' , as: 'destroy_map_organizations'
  get '/:id/:category_id(/:order(/:by))', to: 'organizations#show' , as: 'view_products' 

  root "main#index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
