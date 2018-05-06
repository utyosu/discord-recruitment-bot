module Api
  class ParticipantsController < ApplicationController
    def create
      user = User.find_or_initialize_by(discord_id: participant_params[:discord_id])
      user.update(name: participant_params[:name])

      recruitment = Recruitment.find(params[:recruitment_id])
      return head 400 if recruitment.participants.find_by(user: user)
      participant = recruitment.participants.create!(user: user)
      render json: recruitment, status: 201
    end

    def destroy
      recruitment = Recruitment.find(params[:recruitment_id])
      recruitment.participants.find(params[:id]).destroy
      recruitment.destroy if recruitment.participants.size == 0
      head 200
    end

    private

    def participant_params
      params.require(:participant).permit(:name, :discord_id)
    end
  end
end
