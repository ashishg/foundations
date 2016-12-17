class UserMailer < ActionMailer::Base
  default from: "cdt.no.reply@gmail.com"

  def confirmation_email(user, base_url)
    @confirm_url = base_url + "/users/#{user.id}/validate_confirmation?confirmation_id=#{user.confirmation_id}"
    mail(to: user.email, subject: 'Stanford foundation project: Set your password now')
  end

  def reset_password_email(user, base_url)
    @reset_url = base_url + "/users/#{user.id}/validate_confirmation?confirmation_id=#{user.confirmation_id}"
    mail(to: user.email, subject: 'Stanford foundation project: Request to reset password')
  end


end