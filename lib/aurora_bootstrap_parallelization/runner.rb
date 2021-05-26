module AuroraBootstrapParallelization
  class Runner
    def initialize( opts )
      @config = YAML.load_file( opts[ :config ] )[ "exporters" ]
      @is_cron_job = opts[ :cronjob ]
    end

    def run!
      exporters.map( &:deploy )
    end

    protected

    def exporters
      @config.map do | env_config |
        Exporter.new( env_config, @is_cron_job )
      end
    end
  end
end
