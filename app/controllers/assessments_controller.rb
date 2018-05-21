class AssessmentsController < ApplicationController
  include Wicked::Wizard
  include Wizardable

  before_action :redirect_unless_detainee_exists
  before_action :redirect_if_assessment_already_exists, only: %i[new create]
  before_action :redirect_unless_document_editable, except: :show
  before_action :add_multiples, only: %i[create update]

  helper_method :escort, :assessment

  def new
    form.prepopulate!
    render :new, locals: { form: form }
  end

  def create
    if form.validate form_params
      form.save
      update_document_workflow
      redirect_after_update
    else
      form.prepopulate!
      render :new, locals: { form: form }
    end
  end

  def edit
    form.prepopulate!
    render :edit, locals: { form: form }
  end

  def update
    if form.validate form_params
      form.save
      update_document_workflow
      redirect_after_update
    else
      form.prepopulate!
      render :edit, locals: { form: form }
    end
  end

  def confirm
    if assessment.all_questions_answered?
      assessment.confirm!(user: current_user)
      redirect_to escort_path(escort)
    else
      flash.now[:error] = t('alerts.unable_to_confirm_assessment', assessment: model.to_s)
      render :show
    end
  end

  private

  def escort
    @escort ||= Escort.find(params[:escort_id])
  end

  def form
    @form ||= form_for_step.new(assessment)
  end

  def form_for_step
    "Forms::#{model}::#{step.camelcase}".constantize
  end

  def form_params
    return unless params[step]
    params[step].permit!
  end

  def update_document_workflow
    if assessment.all_questions_answered?
      assessment.unconfirmed!
    else
      assessment.incomplete!
    end
  end

  def redirect_if_assessment_already_exists
    redirect_to show_page if assessment.persisted?
  end

  def redirect_after_update
    if params.key?('save_and_view_summary') || !can_skip?
      redirect_to show_page
    else
      redirect_to next_wizard_path(action: :edit)
    end
  end
end