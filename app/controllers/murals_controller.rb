class MuralsController < ApplicationController
  def index
  end

  def show
    @mural = Mural.published.find_by!(slug: params[:slug])
  end
end
