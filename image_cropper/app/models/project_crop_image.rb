class ProjectCropImage < ActiveRecord::Base
  #belongs_to :project, through: :project_images
  belongs_to :project_image
  belongs_to :user
  belongs_to :tag
  has_many :project_crop_image_cords, dependent: :destroy
  track_who_does_it :creator_foreign_key => "user_id", :updater_foreign_key => "user_id"
  validates_presence_of :project_image_id, :image, :tag

  def image_cords
    cords = {}
    cords[:id] = self.id
    image_cords = self.project_crop_image_cords
    cords[:cords] = []
    image_cords.each do |image_cord|
      cords[:cords] << {
        x: image_cord.x,
        y: image_cord.y
      }
    end
    return cords
  end

end
