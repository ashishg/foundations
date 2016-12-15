class ProjectsController < ApplicationController
  def index
    @sort = params[:sort].nil? ? "votes" : params[:sort]   # FIXME: Injection!!!

    if @sort == "votes"
      order = "vote_count DESC"
    elsif @sort == "date"
      order = "created_at"
    elsif @sort == "name"
      order = "title COLLATE NOCASE"
    end

    @projects = Project.joins("LEFT OUTER JOIN votes ON projects.id = votes.project_id")
      .select("projects.*, COUNT(votes.id) AS vote_count")
      .group("projects.id")
      .order(order)
      #.order(vote_count: :desc)
    if current_user
      @votes = current_user.votes.pluck(:project_id)
    end
  end

  def show
    @project = Project.find(params[:id])
    @comment = Comment.new
  end

  def new
    @projects = Project.all
    @project = Project.new
    @project.cost_step = 1
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    #@project.vote_count = 0
    if @project.save
      redirect_to projects_path
    else
      render :new
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    @project.assign_attributes(project_params)
    changed = @project.changed?
    if @project.save


      if changed
        revision = ProjectRevision.new
        revision.project = @project
        revision.revision = 123  #FIXME!!!
        revision.title = @project.title
        revision.description = @project.description
        revision.cost = @project.cost
        revision.cost_min = @project.cost_min
        revision.address = @project.address
        revision.url = @project.url
        revision.uses_slider = @project.uses_slider
        revision.save

        comment = Comment.new
        comment.project = @project
        comment.user = current_user
        #comment.body = "<i><a href='/projects/" + @project.id.to_s + "/revisions/compare/" + revision.id.to_s + "'>New revision</a></i>"
        comment.project_revision = revision
        comment.save
      end

      redirect_to project_path(@project)
    else
      render :edit
    end
  end

  def vote
    @project = Project.find(params[:id])


    puts "##########################################"
    puts @project.id
    puts current_user.id
    #project.vote_count = project.vote_count + 1
    #project.save

    vote = Vote.find_by(project_id: @project.id, user_id: current_user.id)
    if vote.nil?
      vote = Vote.new
      vote.project = @project
      vote.user = current_user
      vote.save
    else
      vote.destroy
    end

    redirect_to projects_path
  end

  private

  def project_params
    params.require(:project).permit(:number, :title, :description, :cost, :cost_min, :address, :url, :uses_slider)
  end
end
