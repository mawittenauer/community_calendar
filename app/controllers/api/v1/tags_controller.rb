class Api::V1::TagsController < Api::V1::BaseController
  def index
    tags = Tag.active.ordered
    render json: {
      tags: tags.map { |t|
        {
          id: t.id.to_s,
          name: t.name,
          slug: t.slug,
          isActive: t.is_active
        }
      }
    }
  end
end

