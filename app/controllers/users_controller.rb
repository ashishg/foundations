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
    # This action can be called from two different URLs.
    # We might want to split it into two actions in the future.
    if params.key?(:election_id)
      # This is called from GET /admin/elections/:election_id/users/new
      require_admin_auth
      return if performed?
      @election = Election.find(params[:election_id])
      @user = User.new
      @election_user = ElectionUser.new
      @can_create_user_types = can_create_user_types
    else
      # This is called from GET /admin/users/new
      require_superadmin_auth
      return if performed?
      @user = User.new
    end
  end

  def create
    # This action can be called from two different URLs.
    # We might want to split it into two actions in the future.
    if params.key?(:election_id)
      # This is called from POST /admin/elections/:election_id/users
      require_admin_auth
      return if performed?
      @election = Election.find(params[:election_id])
      @user = User.new(user_params)
      @can_create_user_types = can_create_user_types
    else
      # This is called from POST /admin/users
      require_superadmin_auth
      return if performed?
      @user = User.new(user_params)

      # Since this action can create a new superadmin, we require extra security
      if !current_user.authenticate(params[:user][:current_password])
        flash.now[:errors] = ['Wrong password']
        render action: :new
        return
      end
    end

    successes = []
    errors = []
    params[:user][:username].split(/[;,]/).reject(&:blank?).each do |username|
      username = username.strip.downcase

      ActiveRecord::Base.transaction do
        # Create a new user
        user = User.find_by(username: username)
        if user.nil?
          user = User.new
          user.username = username
          user.is_superadmin = params[:user][:is_superadmin] if !params.key?(:election_id)
          if !user.save
            errors << username + ': ' + user.errors.full_messages.join(', ')
            raise ActiveRecord::Rollback
          end
          
          # Send the confirmation email
          begin
            send_confirmation(user, @election)
          rescue Net::SMTPFatalError => e
            errors << username + ': ' + e.message
            raise ActiveRecord::Rollback
          end
        end

        # Add the user to a specific election, if any
        if @election
          @election_user = ElectionUser.new(election_id: @election.id, user_id: user.id, status: params[:status])
          if !@election_user.save
            errors << username + ': ' + @election_user.errors.full_messages.join(', ')
            raise ActiveRecord::Rollback
          end
        end

        successes << username
        log_activity('user_create', user.id.to_s)
      end
    end

    if !successes.empty?
      redirect_to({action: :new}, flash: {notice: 'Users created successfully: ' + successes.join(', '), errors: errors})
    else
      flash.now[:errors] = errors
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
      redirect_to "/"
    end
  end

  def post_login
    username = params[:user][:username].strip.downcase
    previous_url = params[:previous_url]

    user = User.find_by(username: username)
    #if user && user.confirmed && !params[:user][:password].blank? && user.authenticate(params[:user][:password]) 
    if user   # HACKY!!!
      session[:user_id] = user.id
      if !previous_url.blank?
        redirect_to previous_url
      else
        redirect_to "/"
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

  # page to set password and set password
  def validate_confirmation
    user = User.find_by_id(params[:id])
    if !user.confirmation_id.blank? && params[:confirmation_id] == user.confirmation_id
      @confirmed = true
      @confirmation_id = params[:confirmation_id]
    else
      @confirmed = false
    end
  end

  # to set password
  def set_password
    user = User.find_by_id(params[:id])
    # FIXME: we should have an expiration date for password reset!
    if params[:user][:confirmation_id] == user.confirmation_id
      user.confirmed = true
      user.password = params[:user][:password]
      user.password_confirmation = params[:user][:password_confirmation]
      user.confirmation_id = nil
      if user.save
        session[:user_id] = user.id
        if user.superadmin? or user.election_users.count != 1
          redirect_to "/admin"
        else
          redirect_to admin_election_url(user.election_users.first.election)
        end
      else
        @confirmed = true
        @confirmation_id = params[:user][:confirmation_id]
        flash.now[:errors] = user.errors.full_messages
        render action: :validate_confirmation
      end
    else
      # likely under attack
    end
  end

  # reset password
  def reset_password
    username = params[:user][:username].strip.downcase

    if ActivityLog.where("activity = 'reset_password' AND ip_address = ? AND created_at >= ?", request.remote_ip, 1.minute.ago).count >= 8
      redirect_to "/admin/users/reset_password_page" , flash: {errors: ["Please wait one minute and try again."]}
      return
    end

    log_activity('reset_password', username)
    user = User.find_by(username: username)
    if !user.nil?
      send_reset_password_email(user)
      redirect_to "/admin/users/#{user.id}/confirmation_sent"
    else
      redirect_to "/admin/users/reset_password_page", flash: {errors: ["Sorry, there is no such user."]}
    end      
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

  def send_confirmation(user, election)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - ['o', '0', '1', 'l', 'q']
    new_confirmation_id = (0...32).map { chars.sample }.join
    user.update_attribute(:confirmation_id, new_confirmation_id)
    UserMailer.confirmation_email(user, election).deliver
  end

  def send_reset_password_email(user)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - ['o', '0', '1', 'l', 'q']
    new_confirmation_id = (0...32).map { chars.sample }.join
    user.update_attribute(:confirmation_id, new_confirmation_id)
    UserMailer.reset_password_email(user).deliver
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
