# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::MatchesController < Api::V1::ApplicationController
    account_load_and_authorize_resource :match, through: :team, through_association: :matches

    # GET /api/v1/teams/:team_id/matches
    def index
    end

    # GET /api/v1/matches/:id
    def show
    end

    # POST /api/v1/teams/:team_id/matches
    def create
      if @match.save
        render :show, status: :created, location: [:api, :v1, @match]
      else
        render json: @match.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/matches/:id
    def update
      if @match.update(match_params)
        render :show
      else
        render json: @match.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/matches/:id
    def destroy
      @match.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def match_params
        strong_params = params.require(:match).permit(
          *permitted_fields,
          :name,
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays,
          # 🚅 super scaffolding will insert new arrays above this line.
        )

        process_params(strong_params)

        strong_params
      end
    end

    include StrongParameters
  end
else
  class Api::V1::MatchesController
  end
end
