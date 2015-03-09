class ProjectInstancesController < ApplicationController

  def index
    @projects_instances = ProjectInstance.includes(:project, :installations)

    respond_to do |format|
      format.html {
        gon.push({
          :stages => @projects_instances.pluck(:stage).uniq
        })
        render 'index'
      }
      format.csv {
        send_file(Pathname.new(ProjectInstancesExport.new.export).realpath, type: 'text/csv')
      }
    end
  end

  def show
    @project_instance = ProjectInstance.with_deleted.find(params[:id])

    @comments = @project_instance.comments.order(:created_at)
    @comment = Comment.new
  end

  def edit
    @project_instance = ProjectInstance.with_deleted.find(params[:id])
    comment = @project_instance.comments.build
  end

  def update
    @project_instance = ProjectInstance.with_deleted.find(params[:id])
    @installations = @project_instance.installations
    closing_flag = @project_instance.closing

    if @project_instance.update_attributes(project_instance_params)

      if @project_instance.closing != closing_flag
        @installations.each do |installation|
          installation.update_attributes(closing: project_instance_params[:closing])
        end
      end
      redirect_to @project_instance, :notice => "Instance was successfully updated."
    else
      render :action => "edit"
    end
  end

  def new
    nagios_url = params[:nagios_url]

    if nagios_url.present?
      project_id = Project.where("url like ?", "%#{params[:nagios_url]}%").first.try(:id)
      nagios_url[/\A/] = 'http://' unless /\Ahttp(s)?:\/\//.match(nagios_url)
    end

    @project_instance = ProjectInstance.new(project_id: project_id, url: nagios_url)
  end

  def create
    @project_instance = ProjectInstance.new(project_instance_params)
    @project_instance.populate_name

    if @project_instance.save
     redirect_to @project_instance, :notice => "Instance was successfully created."
    else
      render :action => "new"
    end
  end

  def destroy
    @project_instance = ProjectInstance.with_deleted.find(params[:id])
    @project_instance.really_destroy!

    redirect_to project_instances_url
  end

  def soft_delete
    @project_instance = ProjectInstance.with_deleted.find(params[:id])

    if @project_instance.deleted?
      params[:comment][:content][/\A/] =
        '<i style="color: green;"> REACTIVATED </i></br>'

      @project_instance.restore(recursive: true)
    else
      params[:comment][:content][/\A/] =
        '<i style="color: red;"> SHUT DOWN </i></br>'

      @project_instance.destroy
    end

    @project_instance.comments.create(comment_params)
    @installations = @project_instance.installations.with_deleted

    @installations.each do |installation|
      installation.comments.create(comment_params)
    end

    redirect_to project_instances_url
  end

  def deleted_list
    @projects_instances = ProjectInstance.only_deleted
  end

  def nagios_list
    @sites = Nagios.get_sites
    @sites.delete_if{ |site| ProjectInstance.where("url like ?", "%#{site}%").present? }
  end

  private

  def project_instance_params
    params.require(:project_instance).permit(:project_id, :name, :url, :backup_information,
      :stage, :branch, :description, :closing, :closed,
      installations_attributes: [:id, :server_id, :role, :description, :_destroy], comment: [:id, :content, :user_id])
  end

  def comment_params
    params[:comment].permit(:content, :user_id)
  end

end