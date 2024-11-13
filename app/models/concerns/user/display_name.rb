module User::DisplayName
  extend ActiveSupport::Concern

  def display_name
    username.presence || email.split("@").first
  end
end
