class Api::V1::EventsController < Api::V1::BaseController
  def index
    start_param = params[:start]
    end_param   = params[:end]

    unless start_param.present? && end_param.present?
      return render json: { error: "start and end are required (ISO8601)" }, status: :unprocessable_entity
    end

    range_start = Time.iso8601(start_param)
    range_end   = Time.iso8601(end_param)

    events = Event.includes(:category, :venue, :tags)
                 .between(range_start, range_end)

    # calendarIds maps to Category.slug (Schedule-X calendarId)
    if params[:calendarIds].present?
      slugs = params[:calendarIds].to_s.split(",").map(&:strip)
      events = events.joins(:category).where(categories: { slug: slugs })
    end

    # tagIds can be numeric IDs or slugs; I recommend using slugs in the UI.
    if params[:tagIds].present?
      tag_tokens = params[:tagIds].to_s.split(",").map(&:strip)
      events = events.joins(:tags).where(tags: { slug: tag_tokens }).distinct
    end

    if params[:status].present?
      events = events.with_status(params[:status])
    end

    if params[:q].present?
      events = events.search(params[:q])
    end

    render json: { events: events.map { |e| to_schedule_x_event(e) } }
  rescue ArgumentError
    render json: { error: "Invalid start/end format. Use ISO8601." }, status: :unprocessable_entity
  end

  def show
    event = Event.includes(:category, :venue, :tags).find(params[:id])
    render json: { event: to_schedule_x_event(event) }
  end

  private

  # This is the single translation layer that ensures the JSON can be injected into Schedule-X.
  def to_schedule_x_event(e)
    location = e.location_override.presence || e.venue&.full_address

    {
      id: "evt_#{e.id}",
      calendarId: e.category.slug, # IMPORTANT: matches Schedule-X calendars config
      start: e.start_at.iso8601,
      end: e.end_at.iso8601,
      title: e.title,
      description: e.description,
      location: location,
      people: [], # optional if you add organizer later
      meta: {
        categoryId: e.category_id.to_s,
        tagIds: e.tags.map { |t| t.slug },
        status: e.status,
        source: e.source || "admin",
        externalUrl: e.external_url,
        updatedAt: e.last_updated_at&.iso8601
      }
    }
  end
end
