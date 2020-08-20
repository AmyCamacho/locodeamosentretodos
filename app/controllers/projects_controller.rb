class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :destroy]
  skip_before_action :authenticate_user!, only: [:index]

  def index
    if user_signed_in?
      @user = current_user
    end

      if params[:query].present?
        sql_query = " \
        projects.name @@ :query \
        OR roles.name @@ :query \
        OR technologies.name @@ :query \
       "

      @projects = policy_scope(Project).joins(:roles, :technologies).where(sql_query, query: "%#{params[:query]}%")
    else
      @projects = policy_scope(Project)
    end
  end

  def new
    @project = Project.new
    @role = Role.new
    authorize @project
    authorize @role
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    @role = Role.new(role_params)
    @role.project = @project
    authorize @project
    authorize @role
    if @role.save && @project.save
      @collaborator = Collaborator.new(status: "active")
      @collaborator.role = @role
      @collaborator.user = current_user
      @collaborator.save!
      redirect_to project_path(@project)
    else
      render :new
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path
  end

  def show
    authorize @project
    @project_roles = @project.roles
    @role = Role.new
    authorize @role
    @suggestion = Suggestion.new
    authorize @suggestion
    @vote = SuggestionVote.new
    authorize @vote
  end

  def my_projects
    @projects = current_user.projects
    authorize @projects
  end

  private

  def collaborators_counter
    @colaborator_count = Project.collaborators.count
  end

  def project_params
    params.require(:project).permit(:name, :description, :photo)
  end

  def role_params
    params.require(:role).permit(:name, :description)
  end

  def set_project
    @project = Project.find(params[:id])
    authorize @project
  end
end
