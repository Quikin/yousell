class ProductsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  autocomplete
  
  def new
    hobo_new do
      if @product.product_type
        @product.product_variations = []
        for v in @product.product_type.variations
          @product.product_variations << ProductVariation.new(:variation => v)
        end
      end
      if @product.provider && @product.provider_code == ''
        @product.provider_code = @product.provider.code
      end
    end
  end

end