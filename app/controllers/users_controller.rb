class UsersController < ApplicationController
  #before_action :set_no_cache

  # index page to show users list
  def index
    # This action can be called from two different URLs.
    # And each URL requires a different level of user authentication.
    # We might want to split it into two actions in the future.
    if params.key?(:election_id)
      # This is called from GET /admin/elections/:election_id/users
      require_admin_auth
      return if performed?
      @election = Election.find(params[:election_id])
      @users_officer = @election.admin_users
      @users_volunteer = @election.volunteer_users
    else
      # This is called from GET /admin/users
      require_superadmin_auth
      return if performed?
      @users = User.all
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new
    @user.email = params[:email]
    if params[:type] == 'admin'
      @user.isadmin = true
    end 
    if @user.save
      send_confirmation(@user)
      flash[:notice] = "Users created successfully: " + @user.email
      render action: :new
      # redirect_to({action: :new}, flash: {notice: 'Users created successfully: ' + @user.email, errors: "Something went wrong."})
    else
      flash[:errors] = "Something went wrong."
      render action: :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def edit_password
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if !@user.authenticate(params[:user][:current_password])
      flash.now[:errors] = ['Wrong password']
      render action: :edit
    elsif @user.update(user_params)
      redirect_to({action: :show}, flash: {notice: "edited successfully"})
    else
      flash.now[:errors] = @user.errors.full_messages
      render action: :edit
    end
  end

  def update_password
    @user = User.find(params[:id])
    if !@user.authenticate(params[:user][:current_password])
      flash.now[:errors] = ['Wrong current password']
      render action: :edit_password
    elsif @user.update(user_params)
      redirect_to({action: :show}, flash: {notice: "Changed password successfully"})
    else
      flash.now[:errors] = @user.errors.full_messages
      render action: :edit_password
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to action: :index
  end

  def election_user_edit
    @election = Election.find(params[:election_id])
    @user = User.find(params[:id])
    @election_user = ElectionUser.find_by!(user_id: @user.id, election_id: @election.id)
    @can_create_user_types = can_create_user_types
  end

  def election_user_update
    @election = Election.find(params[:election_id])
    @user = User.find(params[:id])
    @election_user = ElectionUser.find_by!(user_id: @user.id, election_id: @election.id)

    @election_user.status = params[:status]
    if @election_user.save
      redirect_to action: :index
    else
      # unlikely
    end
  end

  def election_user_destroy
    @user = User.find(params[:id])
    @election = Election.find(params[:election_id])
    election_user = ElectionUser.find_by!(user_id: @user.id, election_id: @election.id)
    log_activity('election_user_destroy', @user.id.to_s)

    if election_user.destroy
      redirect_to({action: :index}, flash: {notice: "deleted successfully"})
    else
      redirect_to "/admin/elections/#{@election.id}/users", flash: {errors: "Fail to delete"}
    end
  end

  def login
    @previous_url = params[:previous_url]
    if current_user.nil? || !@previous_url.blank?
    else
      redirect_to "/projects"
    end
  end

  def reset_password_form
    login
  end

  def post_login
    username = params[:user][:username].strip.downcase
    previous_url = params[:previous_url]

    user = User.find_by(username: username)
    if user && !params[:user][:password].blank? && params[:user][:password] == user.password_digest
      session[:user_id] = user.id
      if !previous_url.blank?
        redirect_to previous_url
      else
        redirect_to "/projects"
      end
    else
      flash[:error] = 'Wrong username and/or password'
      redirect_to controller: :users, action: :login, previous_url: previous_url
    end
  end

  def logout
    session[:user_id] = nil
    session[:voting_machine_user_id] = nil  # TODO: hacky
    session[:voting_machine_election_id] = nil  # TODO: hacky
    redirect_to action: :login
  end

  # page to set password
  def validate_confirmation
    user = User.find_by(id: params[:id])
    @authentication_status = authenticate_confirmation_id(user, params[:confirmation_id])
    if @authentication_status == :ok
        @confirmation_id = params[:confirmation_id]
    end
  end

  def authenticate_confirmation_id(user, confirmation_id)
      if !user.nil? && !user.confirmation_id.blank? && confirmation_id == user.confirmation_id
        return :ok
      end

      log_activity('validate_confirmation_failure', note: params[:id])
      return :error
  end

  # to set username, password and name
  def set_password_and_info
    user = User.find_by_id(params[:id])
    user.username = params[:user][:username]
    user.password_digest = params[:user][:password]
    user.name = params[:user][:name]
    if user.save
      session[:user_id] = user.id
      redirect_to "/"
    else
      @confirmed = true
      @confirmation_id = params[:user][:confirmation_id]
      flash.now[:errors] = user.errors.full_messages
      render action: :validate_confirmation
    end
  end

  def post_reset_password_form
    @user = User.find_by(email: params[:user][:email])
    if @user
      send_password_reset_email(@user)
      flash[:notice] = "A password reset email has been sent to " + @user.email
      redirect_to "/users/login"
    else
      flash[:errors] = "Something went wrong."
      redirect_to "/users/reset_password_form"
    end
  end

  def reset_password
    user = User.find_by_id(params[:id])
    if user.confirmation_id != params[:confirmation_id]
      flash[:errors] = "Something went wrong."
      redirect_to "/users/reset_password_form"
    end
  end

  # reset password
  def post_reset_password
    user = User.find_by_id(params[:id])
    user.password_digest = params[:user][:password]
    user.save
    flash[:notice] = "Your password has been reset."
    redirect_to "/users/login"
  end

  def resend_confirmation
    # This action can be called from two different URLs.
    # We might want to split it into two actions in the future.
    if params.key?(:election_id)
      # This is called from GET /admin/elections/:election_id/users/:id/resend_confirmation
      require_admin_auth
      return if performed?
      user = User.find(params[:id])
      election = Election.find(params[:election_id])
      ElectionUser.find_by!(user_id: user.id, election_id: election.id)
    else
      # This is called from GET /admin/users/:id/resend_confirmation
      require_superadmin_auth
      return if performed?
      user = User.find(params[:id])
      election = nil
    end
    UserMailer.confirmation_email(user, election).deliver
    redirect_to({action: :index}, flash: {notice: "Confirmation sent"})
  end

  private

  def user_params
    params.require('user').permit(:username, :password, :password_confirmation)
  end

  def send_confirmation(user)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - ['o', '0', '1', 'l', 'q']
    new_confirmation_id = (0...32).map { chars.sample }.join
    user.update_attribute(:confirmation_id, new_confirmation_id)
    UserMailer.confirmation_email(user, request.base_url).deliver_now
  end

  def send_password_reset_email(user)
    UserMailer.reset_password_email(user, request.base_url).deliver_now
  end


  def send_reset_password_email(user)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - ['o', '0', '1', 'l', 'q']
    new_confirmation_id = (0...32).map { chars.sample }.join
    user.update_attribute(:confirmation_id, new_confirmation_id)
    UserMailer.reset_password_email(user, request.base_url).deliver_now
  end

  def can_create_user_types
    [
      ['Volunteer', :volunteer],
      ['Admin', :admin],
    ]
  end

  def require_owner_auth
    unless current_user && (current_user.superadmin? || current_user == User.find_by(id: params[:id]))
      no_access
    end
  end
end
