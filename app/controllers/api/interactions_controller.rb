module Api
  class InteractionsController < ApplicationController
    def index
      render json: Interaction.all
    end

    def create
      interaction = Interaction.find_by(keyword: interaction_params[:keyword])
      if interaction.present?
        interaction.update(interaction_params)
      else
        interaction = Interaction.create!(interaction_params)
      end
      render json: interaction, status: 201
    end

    def destroy_by_keyword
      interaction = Interaction.find_by(keyword: params[:keyword])
      return head 404 if interaction.blank?
      interaction.destroy
      head 200
    end

    def search
      Interaction.all.sort_by{|i|i.keyword.length}.reverse.each do |interaction|
        return render json: {response: interaction.response} if params[:keyword].include?(interaction.keyword)
      end
      return render json: {}
    end

    private

    def interaction_params
      params.require(:interaction).permit(:keyword, :response, :registered_user_name, :registered_user_discord_id)
    end
  end
end
