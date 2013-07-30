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
  
  def print_labels
    @product = Product.find(params[:id])

    temp_file = "#{Rails.root}/tmp/barcode.png"
    temp_pdf = "#{Rails.root}/tmp/labels.pdf"
   
    # Create the barcode PNG
    require 'barby'
    require 'barby/barcode/code_128'
    require 'barby/outputter/png_outputter'
    barby = Barby::Code128B.new(@product.barcode)
    png = Barby::PngOutputter.new(barby).to_png(:height => 25, :margin => 5, :xdim => 1)
    File.open(temp_file, 'w'){|f| f.write png }
    
    # Create the array for the labels PDF
    barcodes = []
    params[:empty_cells].to_i.times do
      barcodes << ""
    end
    params[:number].to_i.times do
      barcodes << temp_file
    end
    
    # Generate the PDF
    
    Prawn::Labels.types = {
      "Apli1285" => {
        "paper_size" => "A4",
        "columns"    => 4,
        "rows"       => 11,
        "top_margin" => 18.0,
        "bottom_margin" => 19.0,
        "left_margin" => 28.5,
        "right_margin" => 18.5
    }}
    
    labels = Prawn::Labels.generate(temp_pdf, barcodes, :type => "Apli1285") do |pdf, barcode|
      unless barcode.blank?
        pdf.image barcode 
        pdf.text @product.barcode, :size => 10
        pdf.text @product.name, :size => 10
      end
    end
    
    # Print or send the PDF back to the browser
    if defined? PRINT_LABELS_COMMAND
      system("#{PRINT_LABELS_COMMAND} #{temp_pdf}")
      flash[:info] = I18n.t("product.show.labels_sent_to_printer")
      redirect_to @product
    else
      send_file temp_pdf, :type => "application/pdf", :disposition => "inline"
    end
  end

  def index  
    hobo_index Product.apply_scopes(
      :search => [params[:search],:name],
      :warehouse_is => params[:warehouse],
      :order_by => parse_sort_param(:name))
  end

end
