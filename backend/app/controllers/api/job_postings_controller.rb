module Api
  class JobPostingsController < ApplicationController
    before_action :authenticate_request!, except: %i[index show]
    before_action :set_posting, only: %i[update destroy]
    before_action :require_owner!, only: %i[update destroy]

    def index
      postings, meta = paginate(JobPosting.published.includes(:company).order(created_at: :desc))
      render json: { job_postings: postings.map { |p| JobPostingSerializer.new(p) }, meta: }
    end

    def show
      posting = JobPosting.includes(:company).find(params[:id])
      # Drafts are only visible to the owning company; everyone else (including
      # unauthenticated requests) gets a 404, same as if the posting didn't exist,
      # so draft IDs can't be enumerated or read by outsiders.
      raise ActiveRecord::RecordNotFound if posting.draft? && !owner?(posting)

      render json: { job_posting: JobPostingSerializer.new(posting) }
    end

    def create
      return render json: { error: "Forbidden" }, status: :forbidden unless current_account.company?

      posting = current_account.profileable.job_postings.new(posting_params)
      if posting.save
        render json: { job_posting: JobPostingSerializer.new(posting) }, status: :created
      else
        render json: { errors: posting.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def mine
      return render json: { error: "Forbidden" }, status: :forbidden unless current_account.company?

      postings, meta = paginate(current_account.profileable.job_postings.includes(:company).order(created_at: :desc))
      render json: { job_postings: postings.map { |p| JobPostingSerializer.new(p) }, meta: }
    end

    def update
      if @posting.update(posting_params)
        render json: { job_posting: JobPostingSerializer.new(@posting) }
      else
        render json: { errors: @posting.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @posting.destroy
      head :no_content
    end

    private

    def set_posting = @posting = JobPosting.find(params[:id])

    def require_owner!
      render json: { error: "Forbidden" }, status: :forbidden unless owner?(@posting)
    end

    # Checks profileable_type rather than role, mirroring Conversation#participant?.
    # Account validates that the two agree, so this is defence in depth for rows
    # written before that validation existed.
    def owner?(posting)
      current_account&.profileable_type == "Company" &&
        posting.company_id == current_account.profileable_id
    end

    def posting_params
      params.require(:job_posting).permit(:title, :description, :requirements, :location, :employment_type, :status)
    end
  end
end
