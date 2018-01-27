class Comfy::Cms::Gallery::Gallery < ActiveRecord::Base

  cms_is_categorized if defined?(ComfortableMexicanSofa)

  self.table_name = :gallery_galleries

  # -- Relationships --------------------------------------------------------
  has_many :photos, :dependent => :destroy

  # -- Validations ----------------------------------------------------------
  validates :title,
            :presence => true
  # attr_accessible :title, :identifier, :description, :full_width, :full_height, :force_ratio_full, :thumb_width, :thumb_height, :force_ratio_thumb, :short_description, :category_ids

  validates :identifier,
            :presence   => true,
            :uniqueness => true,
            :format     => { :with =>  /\A\w[a-z0-9_-]*\z/i }

  # -- Callbacks ------------------------------------------------------------
  before_create :assign_position

  # -- Scopes ---------------------------------------------------------------
  default_scope { order('gallery_galleries.position') }

  private

  def assign_position
    max = Comfy::Cms::Gallery::Gallery.maximum(:position).to_i
    self.position = max ? max + 1 : 0
  end

end