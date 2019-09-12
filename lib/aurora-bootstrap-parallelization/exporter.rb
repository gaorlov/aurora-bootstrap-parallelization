module AuroraBootstrapParallelization
  class Exporter
    def initialize( config )
      @config = config
    end

    def deploy
      # make file named tmp/#{self.name}-job.yml
      # run kubectl create
    end

    def manifest
      @manifest ||= YAML.load(ERB.new(File.read("../../templates/job.yml")).result( self ))
    end

    def name
      @name ||= "#{config[:host]}-exporter"
    end

    def env
      @env ||= config[:env]
    end

    def version
      @version ||= config[:version]
    end
  end
end