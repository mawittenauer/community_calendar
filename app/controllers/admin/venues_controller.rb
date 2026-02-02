class Admin::VenuesController < Admin::BaseController
  before_action :set_admin_venue, only: %i[ show edit update destroy ]

  # GET /admin/venues or /admin/venues.json
  def index
    @admin_venues = Admin::Venue.all
  end

  # GET /admin/venues/1 or /admin/venues/1.json
  def show
  end

  # GET /admin/venues/new
  def new
    @admin_venue = Admin::Venue.new
  end

  # GET /admin/venues/1/edit
  def edit
  end

  # POST /admin/venues or /admin/venues.json
  def create
    @admin_venue = Admin::Venue.new(admin_venue_params)

    respond_to do |format|
      if @admin_venue.save
        format.html { redirect_to @admin_venue, notice: "Venue was successfully created." }
        format.json { render :show, status: :created, location: @admin_venue }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin_venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/venues/1 or /admin/venues/1.json
  def update
    respond_to do |format|
      if @admin_venue.update(admin_venue_params)
        format.html { redirect_to @admin_venue, notice: "Venue was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @admin_venue }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @admin_venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/venues/1 or /admin/venues/1.json
  def destroy
    @admin_venue.destroy!

    respond_to do |format|
      format.html { redirect_to admin_venues_path, notice: "Venue was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_venue
      @admin_venue = Admin::Venue.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def admin_venue_params
      params.expect(admin_venue: [ :name, :address1, :address2, :city, :state, :postal_code, :notes, :map_url ])
    end
end
