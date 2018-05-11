module Api
  class InteractionsController < ApplicationController
    def index
      render json: Interaction.all
    end

    def create
      user = User.find_or_initialize_by(discord_id: params[:interaction][:registered_user_discord_id])
      user.update(name: params[:interaction][:registered_user_name])
      interaction = Interaction.create!(interaction_params.merge(user: user))
      render json: interaction, status: 201
    end

    def destroy_by_keyword
      interactions = Interaction.where(keyword: params[:keyword])
      return head 404 if interactions.blank?
      interactions.destroy_all
      head 200
    end

    def search
      interaction = Interaction.all.select{|interaction| params[:keyword] =~ /#{interaction.keyword}/}.sample
      return render json: {response: interaction.response} if interaction.present?
      return render json: {}
    end

    private

    def interaction_params
      params.require(:interaction).permit(:keyword, :response)
    end
  end
end
