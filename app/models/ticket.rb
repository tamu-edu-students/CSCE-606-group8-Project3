class Ticket < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true

  enum :status, { open: 0, pending: 1, resolved: 2, closed: 3 }, validate: true
  enum :priority, { low: 0, normal: 1, high: 2 }, validate: true

  validates :subject, presence: true
  validates :description, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :requester, presence: true

  before_save :set_closed_at, if: :status_changed?

  private

  def set_closed_at
    if status == "closed"
      self.closed_at = Time.current
    elsif status_was == "closed" && status != "closed"
      self.closed_at = nil
    end
  end
end
