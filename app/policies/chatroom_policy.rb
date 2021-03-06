class ChatroomPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def chatroom?
    user == record.application_request.user || user == record.application_request.project.user
  end
end
