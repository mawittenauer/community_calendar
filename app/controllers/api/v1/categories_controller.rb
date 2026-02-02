class Api::V1::CategoriesController < Api::V1::BaseController
  def index
    categories = Category.active.ordered
    render json: {
      categories: categories.map { |c|
        {
          id: c.id.to_s,
          name: c.name,
          slug: c.slug,
          sortOrder: c.sort_order,
          isActive: c.is_active
        }
      }
    }
  end
end
