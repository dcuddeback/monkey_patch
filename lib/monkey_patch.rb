require 'rubygems'

module MonkeyPatch
  class Error < RuntimeError
  end

  class MissingGem < Error
    attr_reader :gem_name, :version

    def initialize(gem_name, version)
      @gem_name = gem_name
      @version  = version
    end

    def to_s
      "attempted to patch missing gem: #{gem_name} v#{version}"
    end
  end

  class UpdateRequired < Error
    attr_reader :gem, :version

    def initialize(gem, version)
      @gem     = gem
      @version = version
    end

    def to_s
      "attempted to patch wrong version of gem: #{gem.name} v#{version} (installed version is #{gem.version.to_s})"
    end
  end

  class Patcher
    attr_reader :gem, :version

    def initialize(gem, version)
      @gem     = gem
      @version = version
    end

    def announce(patch)
      MonkeyPatch.logger && MonkeyPatch.logger.info("MonkeyPatch (#{gem} v#{version}): #{patch}")
    end
  end

  class << self
    attr_accessor :logger

    def for(gem_name, version, &block)
      gem = find_gem(gem_name)

      raise MissingGem.new(gem_name, version) if gem.nil?
      raise UpdateRequired.new(gem, version)  if gem.version.to_s != version

      block.call(MonkeyPatch::Patcher.new(gem_name, version))
    end

    private

    def find_gem(name)
      if Gem::Specification.respond_to?(:find_all_by_name)
        Gem::Specification.find_all_by_name(name.to_s).first
      else
        Gem.source_index.find_name(name.to_s).first
      end
    end
  end
end

if defined?(Rails) && Rails::VERSION::MAJOR >= 3
  require 'monkey_patch/railtie'
end
