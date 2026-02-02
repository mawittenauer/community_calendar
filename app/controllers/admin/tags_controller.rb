class Admin::TagsController < Admin::BaseController
  before_action :set_admin_tag, only: %i[ show edit update destroy ]

  # GET /admin/tags or /admin/tags.json
  def index
    @admin_tags = Admin::Tag.all
  end

  # GET /admin/tags/1 or /admin/tags/1.json
  def show
  end

  # GET /admin/tags/new
  def new
    @admin_tag = Admin::Tag.new
  end

  # GET /admin/tags/1/edit
  def edit
  end

  # POST /admin/tags or /admin/tags.json
  def create
    @admin_tag = Admin::Tag.new(admin_tag_params)

    respond_to do |format|
      if @admin_tag.save
        format.html { redirect_to @admin_tag, notice: "Tag was successfully created." }
        format.json { render :show, status: :created, location: @admin_tag }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/tags/1 or /admin/tags/1.json
  def update
    respond_to do |format|
      if @admin_tag.update(admin_tag_params)
        format.html { redirect_to @admin_tag, notice: "Tag was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @admin_tag }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @admin_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/tags/1 or /admin/tags/1.json
  def destroy
    @admin_tag.destroy!

    respond_to do |format|
      format.html { redirect_to admin_tags_path, notice: "Tag was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_tag
      @admin_tag = Admin::Tag.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def admin_tag_params
      params.expect(admin_tag: [ :name, :slug, :is_active ])
    end
end
