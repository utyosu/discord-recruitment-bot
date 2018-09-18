module Api
  class RecruitmentsController < ApplicationController
    def index
      @recruitments = Recruitment.where(enable: true)
    end

    def create
      recruitment = Recruitment.create!(recruitment_params)
      render json: recruitment, status: 201
    end

    def update
      recruitment = Recruitment.find(params[:id]).update(recruitment_params)
      render json: recruitment
    end

    def destroy
      Recruitment.find(params[:id]).update(enable: false)
      head 200
    end

    def resurrection
      recruitment = Recruitment.order("updated_at ASC").where(enable: false).last
      recruitment.set_label_id
      recruitment.update(enable: true)
      render json: recruitment, status: 200
    end

    private

    def recruitment_params
      params.require(:recruitment).permit(:content, :reserve_at, :tweet_id, :notificated)
    end
  end
end
