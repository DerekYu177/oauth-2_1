# frozen_string_literal: true

require 'ulid'

module ULIDable
  extend ActiveSupport::Concern

  REGEX = /[0-7][0-9A-HJKMNP-TV-Z]{25}/

  included do
    after_initialize :set_ulid
  end

  def set_ulid
    self.id ||= ULID.generate
  end
end
