class ReplaysController < ApplicationController

  def show
    respond_to do |format|
      format.html {
        @cells = Cell.order(:x).preload(:token).to_a.group_by(&:y)
      }
      format.json {
        prefix = Rails.env.production? ? '../..' : '.'
        res = JSON.parse("[#{File.readlines("#{prefix}/state.log.#{params[:id]}").join(",")}]")
        res = res.drop_while{|x| !x[0]['board_id'] }.tap(&:shift)
        render json: res
      }
    end
  end
end
