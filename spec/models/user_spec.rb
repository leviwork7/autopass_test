require "rails_helper"

RSpec.describe User, type: :model do
  it { expect { create(:user) }.to change { User.count }.by(1) }
end
