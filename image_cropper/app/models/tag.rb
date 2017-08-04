class Tag < ActiveRecord::Base
  has_many :project_users
  validates_presence_of :name
  validates_uniqueness_of :name
  validates :name, format: { with: /\A[a-zA-Z0-9]+\z/,
                             message: "only allows letters and numbers" }
end
