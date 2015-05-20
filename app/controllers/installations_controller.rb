class InstallationsController < ApplicationController
  before_action :authenticate_user!

  respond_to :html, :json

  def index

    gon.push({
      :roles => Installation.pluck(:role).uniq
    })

    respond_to do |format|
      format.html {
        @installations = Installation.all
        render 'index'
      }
      format.csv {
        send_file(Pathname.new(InstallationsExport.new.export).realpath, type: 'text/csv')
      }
    end
  end

  def show
    set_installation

    @comments = @installation.comments.order(:created_at)
    @comment = Comment.new

  end

  def new
    @installation = Installation.new
  end

  def edit
    set_installation
  end

  def create
    @installation = Installation.new(installation_params)

    flash[:notice] = 'Installation was successfully created' if @installation.save
    respond_with(@installation, location: installations_path)
  end

  def update
    set_installation

    old_closing = @installation.closing

    if @installation.update_attributes(installation_params)
      if old_closing != @installation.closing
        status = @installation.closing ? "scheduled for close down" : "unscheduled for close down"
        SlackChannel.post("#labs", "*#{@installation.name}* installation has been #{status}")
      end
      flash[:notice] = 'Installation was successfully updated'
    end
    respond_with(@installation)
  end

  def destroy
    set_installation
    @installation.really_destroy!

    flash[:notice] = 'Installation was successfully deleted'
    respond_with(@installation)
  end

  def soft_delete
    @installation = Installation.with_deleted.find(params[:id])

    deleted = @installation.deleted?
    message = "*#{@installation.name}* installation has been #{deleted ? 'restarted' : 'shut down'} with the following comment: " +
      "```#{params[:comment][:content]}```"

    if deleted
      params[:comment][:content][/\A/] = '<i style="color: green;"> RESTARTED </i><br>'
      SlackChannel.post("#labs", message)
      @installation.restore
    else
      params[:comment][:content][/\A/] = '<i style="color: red;"> SHUT DOWN </i><br>'
      SlackChannel.post("#labs", message)
      @installation.destroy
    end

    @installation.comments.create(comment_params)
    redirect_to installations_url
  end

  def deleted_list
    @installations = Installation.only_deleted

    gon.push({
      :roles => Installation.only_deleted.pluck(:role).uniq
    })

    respond_to do |format|
      format.html
    end
  end

  private
    def set_installation
      @installation = Installation.with_deleted.find(params[:id])
    end

    def installation_params
      params.require(:installation).permit(:project_instance_id,
        :server_id, :role, :description, :closing)
    end

    def comment_params
      params[:comment].permit(:content, :user_id)
    end
end
