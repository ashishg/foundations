class Project < ActiveRecord::Base
  belongs_to :user
  has_many :project_revisions
  has_many :comments

  validates :title, presence: true
  validates :description, presence: true
  validates :cost, numericality: {only_integer: true, greater_than: 0}
  validates :cost_min, numericality: {only_integer: true, greater_than_or_equal_to: 0}, allow_blank: true
  validate :validate_cost_min

  def validate_cost_min
    # TODO: check cost_step too
    if uses_slider and cost_min.blank?
      errors.add(:cost_min, "can't be blank")
      return
    end
    return if cost_min.blank? or cost.blank?
    if cost_min.to_i >= cost.to_i
      errors.add(:cost_min, 'must be less than cost max')
    end
  end

  def cost_string
    extend ActionView::Helpers::NumberHelper
    if !uses_slider
      return "$" + number_with_delimiter(cost)
    end
    return "$" + number_with_delimiter(cost_min) + " - $" + number_with_delimiter(cost)
  end
end
