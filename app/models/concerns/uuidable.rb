# frozen_string_literal: true

module UUIDable
  extend ActiveSupport::Concern

  included do
    after_initialize :set_uuid
  end

  private

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
