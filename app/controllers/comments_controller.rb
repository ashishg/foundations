class CommentsController < ApplicationController
  def create
    project = Project.find(params[:project_id])

    comment = Comment.new(comment_params)
    comment.project = project
    comment.user = current_user
    #comment.vote_count = 0
    comment.save

    #comment.user = current_user
    redirect_to project_path(project)
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
