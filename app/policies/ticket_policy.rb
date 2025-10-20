class TicketPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.requester? || user.agent? || user.admin?
  end

  def new?
    create?
  end

  def update?
    return true if user.admin?
    return true if user.agent? && record.requester != user
    return true if user.requester? && record.requester == user && record.open?
    false
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? || (user.requester? && record.requester == user && record.open?)
  end

  def assign?
    user.agent? || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.agent?
        scope.all
      else
        scope.where(requester: user)
      end
    end
  end
end
