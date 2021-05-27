module AuroraBootstrapParallelization
  class Runner
    def initialize( opts )
      @config = YAML.load_file( opts[ :config ] )[ "exporters" ]
      @exporter_class = opts[ :cronjob ] ? CronjobExporter : JobExporter
    end

    def run!
      exporters.map( &:deploy )
    end

    protected

    def exporters
      @config.map do | env_config |
        @exporter_class.new( env_config )
      end
    end
  end
end
