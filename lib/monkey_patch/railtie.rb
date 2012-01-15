module MonkeyPatch
  class Railtie < Rails::Railtie
    initializer "monkey_patch.initialization" do
      MonkeyPatch.logger = Rails.logger

      Dir.glob Rails.root.join("config/patches/**/*.rb") do |file|
        require file
      end
    end
  end
end
