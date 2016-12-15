class ProjectRevisionsController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    @project_revisions = @project.project_revisions.order(id: :desc)
  end

  def compare
    @project = Project.find(params[:project_id])
    @revision1 = ProjectRevision.find(params[:project_revision_id1])
    if !params[:project_revision_id2].nil?
      @revision2 = ProjectRevision.find(params[:project_revision_id2])
    else
      @revision2 = ProjectRevision.where("project_id = ? AND id < ?", @revision1.project_id, @revision1.id).order(id: :desc).first
      #puts 'xxx'
      #puts @revision2.id
      #puts 'yyy'
    end
    @revision1_json = @revision1.as_json(only: [:id, :title, :description], methods: [:cost_string])
    @revision2_json = @revision2.as_json(only: [:id, :title, :description], methods: [:cost_string])
  end
end
