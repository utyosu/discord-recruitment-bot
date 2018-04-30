module Api
  class RecruitmentsController < ApplicationController
    def index
      @recruitments = Recruitment.all
    end

    def create
      recruitment = Recruitment.create!(recruitment_params)
      render json: recruitment, status: 201
    end

    def destroy
      Recruitment.find(params[:id]).destroy
      head 200
    end

    private

    def recruitment_params
      params.require(:recruitment).permit(:content, :expired_at)
    end
  end
end
