class Admin::VenuesController < Admin::BaseController
  before_action :set_venue, only: %i[ show edit update destroy ]

  # GET /admin/venues or /admin/venues.json
  def index
    @venues = Venue.all
  end

  # GET /admin/venues/1 or /admin/venues/1.json
  def show
  end

  # GET /admin/venues/new
  def new
    @venue = Venue.new
  end

  # GET /admin/venues/1/edit
  def edit
  end

  # POST /admin/venues or /admin/venues.json
  def create
    @venue = Venue.new(venue_params)

    respond_to do |format|
      if @venue.save
        format.html { redirect_to admin_venue_path(@venue), notice: "Venue was successfully created." }
        format.json { render :show, status: :created, location: @venue }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/venues/1 or /admin/venues/1.json
  def update
    respond_to do |format|
      if @venue.update(venue_params)
        format.html { redirect_to admin_venue_path(@venue), notice: "Venue was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @venue }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/venues/1 or /admin/venues/1.json
  def destroy
    @venue.destroy!

    respond_to do |format|
      format.html { redirect_to admin_venues_path, notice: "Venue was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_venue
      @venue = Venue.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def venue_params
      params.expect(venue: [ :name, :address1, :address2, :city, :state, :postal_code, :notes, :map_url ])
    end
end
