class Comfy::Cms::Gallery::Photo < ActiveRecord::Base

  self.table_name = :gallery_photos

  upload_options = (ComfortableMexicanSofa.config.upload_file_options || {}).merge(
      :styles => lambda { |image|
        g = image.instance.gallery
        f_settings = "#{g.full_width}x#{g.full_height}#{g.force_ratio_full?? '#' : '>'}"
        t_settings = "#{g.thumb_width}x#{g.thumb_height}#{g.force_ratio_thumb?? '#' : '>'}"
        {
            :full         => { :geometry => f_settings },
            :thumb        => { :geometry => t_settings },
            :admin_full   => '800x600>',
            :admin_thumb  => '40x30#'
        }
      },
      :path => ':rails_root/paperclip/galleries/:gallery_id/:id_partition/:style/:filename',
      :url => '/system/paperclip/galleries/:gallery_id/:id_partition/:style/:filename',
  )
  has_attached_file :image, upload_options

  attr_accessor :thumb_crop_x, :thumb_crop_y, :thumb_crop_w, :thumb_crop_h,
                :full_crop_x, :full_crop_y, :full_crop_w, :full_crop_h

  # -- Relationships --------------------------------------------------------
  belongs_to :gallery

  # -- Callbacks ------------------------------------------------------------
  before_create :assign_position

  # -- Validations ----------------------------------------------------------
  validates :gallery_id,
            :presence => true
  validates_attachment_presence :image,
                                :message      => 'There was no file uploaded!'
  validates_attachment_content_type :image,
                                    :content_type => %w(image/jpeg image/pjpeg image/gif image/png image/x-png),
                                    :message      => 'Please only upload .jpg, .jpeg, .gif or .png files.'
  validates_attachment_size :image,
                            :less_than    => 20.megabytes

  # attr_accessible :gallery, :title, :description, :image, :embed_code

  # -- Scopes ---------------------------------------------------------------
  default_scope { order('gallery_photos.position') }

  # -- Instance Methods -----------------------------------------------------
  def image_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(image.path(style))
  end

  def force_aspect?
    self.gallery.force_ratio_full? || self.gallery.force_ratio_thumb?
  end

  def has_media?
    self.embed_code.present?
  end

  private

  def assign_position
    max = self.gallery.photos.maximum(:position)
    self.position = max ? max + 1 : 0
  end

  # interpolate in paperclip
  Paperclip.interpolates :gallery_id do |attachment, style|
    return super() if attachment.nil?

    attachment.instance.gallery.id.to_s
  end
end