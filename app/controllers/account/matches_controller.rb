class Account::MatchesController < Account::ApplicationController
  account_load_and_authorize_resource :match, through: :team, through_association: :matches

  # GET /account/teams/:team_id/matches
  # GET /account/teams/:team_id/matches.json
  def index
    delegate_json_to_api
  end

  # GET /account/matches/:id
  # GET /account/matches/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/matches/new
  def new
  end

  # GET /account/matches/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/matches
  # POST /account/teams/:team_id/matches.json
  def create
    respond_to do |format|
      if @match.save
        format.html { redirect_to [:account, @match], notice: I18n.t("matches.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @match] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/matches/:id
  # PATCH/PUT /account/matches/:id.json
  def update
    respond_to do |format|
      if @match.update(match_params)
        format.html { redirect_to [:account, @match], notice: I18n.t("matches.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @match] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/matches/:id
  # DELETE /account/matches/:id.json
  def destroy
    @match.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :matches], notice: I18n.t("matches.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
