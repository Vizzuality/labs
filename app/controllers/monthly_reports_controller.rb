class MonthlyReportsController < ApplicationController
  before_action :set_project, only: [:new, :index]

  def index
    @monthly_reports = @project.monthly_reports.order(:report_date)
  end

  def new
    @monthly_report = @project.monthly_reports.build
  end

  def create
    @monthly_report = MonthlyReport.new(monthly_report_params)
    if @monthly_report.save
      redirect_to project_monthly_reports_path(@monthly_report.project)
    else
      render :new
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def monthly_report_params
    params.require(:monthly_report).permit(
      :money_spent, :design_days, :frontend_days,
      :backend_days, :data_days, :research_days,
      :project_id, :report_date
    )
  end
end
