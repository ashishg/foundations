class ProjectRevision < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  def cost_string
    extend ActionView::Helpers::NumberHelper
    if !uses_slider
      return "$" + number_with_delimiter(cost)
    end
    return "$" + number_with_delimiter(cost_min) + " - $" + number_with_delimiter(cost)
  end
end
