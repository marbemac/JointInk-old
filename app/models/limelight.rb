module Limelight #:nodoc:

  # Include this module to enable image handling on a document
  # @example Add image handling.
  #   require "limelight"
  #   class Person
  #     include Limelight::Images
  #   end
  module Images
    extend ActiveSupport::Concern

    included do
      #active_image_version :integer, :default => 0
      #remote_image_url :string
      ##images :some_array, :default => []

      attr_accessible :remote_image_url
    end

    def image_ratio(version=nil)
      return nil if self.class.name == 'User' && use_fb_image
      return nil if self.class.name == 'Channel' && use_freebase_image
      return nil if images.length == 0 || (version && images.length <= version)

      if version
        images[version]['w'].to_f / images[version]['h'].to_f
      else
        images[0]['w'].to_f / images[0]['h'].to_f
      end
    end

    def image_width(version=nil)
      return nil if self.class.name == 'User' && use_fb_image
      return nil if self.class.name == 'Channel' && use_freebase_image
      return nil if images.length == 0 || (version && images.length <= version)

      if version
        images[version]['w']
      else
        images[0]['w']
      end
    end

    def image_height(version=nil)
      return nil if self.class.name == 'User' && use_fb_image
      return nil if self.class.name == 'Channel' && use_freebase_image
      return nil if images.length == 0 || (version && images.length <= version)

      if version
        images[version]['h']
      else
        images[0]['h']
      end
    end

    def size_dimensions
      {:small => 100, :normal => 300, :large => 600}
    end

    def available_sizes
      [:small, :normal, :large]
    end

    def available_modes
      [:square, :fit]
    end

    def image_filepath
      if Rails.env.production?
        "http://res.cloudinary.com/0lmhydab/image"
      elsif Rails.env.staging?
        "http://res.cloudinary.com/xpgzvxkw/image"
      else
        "http://res.cloudinary.com/limelight/image"
      end
    end

    def current_image_filepath
      "#{image_filepath}/#{active_image_version}"
    end

    def image_url(mode, size=nil, version=nil, original=false)
      version = active_image_version unless version
      if self.class.name == 'User' && use_fb_image
        if mode == :square
          "#{image_filepath}/facebook/w_#{size_dimensions[size]},h_#{size_dimensions[size]},c_thumb,g_faces/#{fbuid}.jpg"
        else
          "#{image_filepath}/facebook/w_#{size_dimensions[size]}/#{fbuid}.jpg"
        end
      else
        if version == 0
          if self.class.name == 'User'
            if twitter_handle
              if mode == :square
                "#{image_filepath}/twitter_name/w_#{size_dimensions[size]},h_#{size_dimensions[size]},c_thumb,g_faces/#{twitter_handle}.jpg"
              else
                "#{image_filepath}/twitter_name/w_#{size_dimensions[size]}/#{fbuid}.jpg"
              end
            else
              "http://www.gravatar.com/avatar?d=mm&f=y&s=#{size_dimensions[size]}"
            end
          elsif self.class.name == 'Channel'
            if use_freebase_image
              "https://usercontent.googleapis.com/freebase/v1/image#{freebase_id}?maxheight=#{size_dimensions[size]}&maxwidth=#{size_dimensions[size]}&mode=#{mode == :fit ? 'fit' : 'fillcropmid'}&pad=true"
            else
              "http://img.p-li.me/defaults/topics/#{size}.gif"
            end
          end
        else
          if mode == :square
            "#{image_filepath}/upload/w_#{size_dimensions[size]},h_#{size_dimensions[size]},c_thumb,g_faces/#{id}_#{active_image_version}.jpg"
          else
            "#{image_filepath}/upload/w_#{size_dimensions[size]},c_fit/#{id}_#{active_image_version}.jpg"
          end

        end
      end
    end

    # Saves a new image from the remote_image_url currently specified on the model
    def save_remote_image(url)
      begin
        i = Magick::Image::read(url).first
      rescue => e
        return
      end

      begin
        Cloudinary::Uploader.upload(url, :public_id => "#{id}_#{self.images.length+1}")
      rescue => e
        return
      end

      self.images << {
              'remote_url' => url,
              'w' => i.columns,
              'h' => i.rows
      }

      self.active_image_version = self.images.length

      save
    end

    def process_images
      if !remote_image_url.blank? && active_image_version == 0
        save_remote_image(remote_image_url)
      end
    end
  end
end
