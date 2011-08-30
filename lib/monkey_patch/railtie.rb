module MonkeyPatch
  class Railtie < Rails::Railtie
    initializer "monkey_patch.initialization" do |app|
      MonkeyPatch.logger = Rails.logger
    end
  end
end
