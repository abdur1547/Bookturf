# frozen_string_literal: true

module Api::V0::Users
  class UploadAvatarOperation < BaseOperation
    MAX_AVATAR_SIZE = 5.megabytes
    ALLOWED_MIME_TYPES = %w[image/jpeg image/png image/webp].freeze
    ALLOWED_EXTENSIONS = %w[jpg jpeg png webp].freeze

    def call(params, current_user)
      @params = params
      @current_user = current_user

      yield validate_file
      yield upload_file
      success_response
    end

    private

    attr_reader :params, :current_user, :avatar_url

    def validate_file
      file = params[:avatar]

      return Failure({ avatar: [ "No file provided" ] }) if file.blank?

      # Check file size
      if file.size > MAX_AVATAR_SIZE
        return Failure({ avatar: [ "File size exceeds 5MB limit" ] })
      end

      # Check MIME type
      unless ALLOWED_MIME_TYPES.include?(file.content_type)
        return Failure({ avatar: [ "Invalid file type. Allowed: jpg, jpeg, png, webp" ] })
      end

      # Check file extension
      extension = File.extname(file.original_filename).downcase.delete(".")
      unless ALLOWED_EXTENSIONS.include?(extension)
        return Failure({ avatar: [ "Invalid file extension. Allowed: jpg, jpeg, png, webp" ] })
      end

      Success()
    end

    def upload_file
      file = params[:avatar]

      # Generate unique filename
      filename = "avatars/#{current_user.id}_#{Time.current.to_i}_#{SecureRandom.hex(4)}" \
                 "#{File.extname(file.original_filename)}"

      # For now, store as a URL (e.g., Cloud storage URL)
      # TODO: Implement actual file storage (ActiveStorage, S3, etc.)
      @avatar_url = "/uploads/#{filename}"

      # Update user avatar_url
      unless current_user.update(avatar_url: @avatar_url)
        return Failure(current_user.errors.to_h)
      end

      Success()
    end

    def success_response
      {
        json: {
          avatar_url: @avatar_url,
          message: "Avatar uploaded successfully"
        }
      }
    end
  end
end
