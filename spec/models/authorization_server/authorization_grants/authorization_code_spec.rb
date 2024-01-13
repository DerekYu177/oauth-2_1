# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(AuthorizationServer::AuthorizationGrants::AuthorizationCode, type: :model) do
  it 'sets expired_at', :freeze_time do
    expect(described_class.new.expires_at).to(eq(Time.now.utc + 10.minutes))
  end

  it 'has a ULID as a primary key' do
    expect(described_class.new.id).to(match(ULIDable::REGEX))
  end
end
