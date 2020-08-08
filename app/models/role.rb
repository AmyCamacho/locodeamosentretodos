class Role < ApplicationRecord
  belongs_to :project
  has_many :collaborators, dependent: :destroy
  has_many :application_requests, dependent: :destroy
  has_many :users, through: :collaborators
  has_many :requirements, dependent: :destroy
  validates :name, presence: true


  # scope :open_roles, -> { where(collaborators: nil) }

  def open?
    self.collaborators.empty?
  end

end
