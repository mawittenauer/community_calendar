class Api::V1::EventsController < Api::V1::BaseController
  def index
    start_param = params[:start]
    end_param   = params[:end]

    unless start_param.present? && end_param.present?
      return render json: { error: "start and end are required (ISO8601)" }, status: :unprocessable_entity
    end

    def parse_time_param(value)
      v = value.to_s.strip
      Rails.logger.debug "DEBUG: Parsing time param: #{v.inspect}"
      # Try multiple parsing approaches
      begin
        # First try Time.parse which is more lenient
        parsed = Time.parse(v)
        Rails.logger.debug "DEBUG: Time.parse succeeded: #{parsed.inspect}"
        result = parsed.in_time_zone
        Rails.logger.debug "DEBUG: Converted to time zone: #{result.inspect}"
        result
      rescue ArgumentError => e
        Rails.logger.error "DEBUG: Time.parse failed for #{v.inspect}: #{e.message}"
        begin
          # Fallback to DateTime.parse
          parsed = DateTime.parse(v)
          Rails.logger.debug "DEBUG: DateTime.parse succeeded: #{parsed.inspect}"
          result = parsed.in_time_zone
          Rails.logger.debug "DEBUG: DateTime converted to time zone: #{result.inspect}"
          result
        rescue ArgumentError => e2
          Rails.logger.error "DEBUG: DateTime.parse also failed: #{e2.message}"
          nil
        end
      end
    end

    range_start = parse_time_param(start_param)
    range_end   = parse_time_param(end_param)

    if range_start.blank? || range_end.blank?
      return render json: { error: "Invalid start/end format. Use ISO8601." }, status: :unprocessable_entity
    end

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
