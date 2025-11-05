class CommentPolicy < ApplicationPolicy
  def create?
    return false if record.ticket.resolved?

    if user.requester?
      record.ticket.requester == user && record.visibility_public?
    elsif user.agent? || user.admin?
      true
    else
      false
    end
  end
end
