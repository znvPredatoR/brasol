Spree::ProductsController.class_eval do
  before_filter :define_2d_option_matrix, :only => :show

  def define_2d_option_matrix
    variants = Spree::Config[:show_zero_stock_products] ?
        @product.variants.active.select { |a| !a.option_values.empty? } :
        @product.variants.active.select { |a| !a.option_values.empty? && a.in_stock }

    return if variants.empty?

    if @product.option_types.select { |a| a.name.start_with? 'size' }.empty? &&
        @product.option_types.select { |a| a.name.start_with? 'color' }.empty?
      @other_variants_present = true
      return
    end

    variant_ids = {}
    sizes = []
    colors = []
    variants.each do |variant|
      active_size = variant.option_values.select { |a| a.option_type.name.start_with? 'size' }.first
      active_color = variant.option_values.select { |a| a.option_type.name.start_with? 'color' }.first

      if active_color.present? and active_size.present?
        variant_ids[active_size.id.to_s + '_' + active_color.id.to_s] = variant.id
      elsif active_color.present?
        variant_ids[active_color.id.to_s] = variant.id
      elsif active_size.present?
        variant_ids[active_size.id.to_s] = variant.id
      end

      sizes << active_size unless active_size.nil?
      colors << active_color unless active_color.nil?
    end
    size_sort = Hash['S', 0, 'M', 1, 'L', 2, 'XL', 3]
    @double_option = {'sizes' => sizes.sort_by { |s| size_sort[s.presentation] || 0 }.uniq,
                      'colors' => colors.uniq,
                      'variant_ids' => variant_ids}
  end
end