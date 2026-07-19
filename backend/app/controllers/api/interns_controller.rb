module Api
  class InternsController < ApplicationController
    before_action :authenticate_request!
    before_action :require_company!, only: %i[index show]

    def index
      interns = Intern.order(created_at: :desc)
      render json: { interns: interns.map { |i| InternSerializer.new(i) } }
    end

    def show
      intern = Intern.find(params[:id])
      render json: { intern: InternSerializer.new(intern) }
    end

    def update_me
      intern = current_account.profileable
      return render json: { error: "Forbidden" }, status: :forbidden unless current_account.intern?

      if intern.update(intern_params)
        render json: { intern: InternSerializer.new(intern) }
      else
        render json: { errors: intern.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def require_company!
      render json: { error: "Forbidden" }, status: :forbidden unless current_account.company?
    end

    def intern_params
      params.require(:intern).permit(:name, :university, :major, :graduation_year, :skills, :bio)
    end
  end
end
