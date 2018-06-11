class MovesController < ApplicationController
  before_action :redirect_unless_document_editable
  helper_method :escort, :form

  def update
    if form.validate(params[:move])
      form.save
      redirect_to escort_path(escort)
    else
      render :edit
    end
  end

  private

  def escort
    @escort ||= Escort.find(params[:escort_id])
  end

  def form
    @form ||= Forms::Move.new(escort.move)
  end
end
