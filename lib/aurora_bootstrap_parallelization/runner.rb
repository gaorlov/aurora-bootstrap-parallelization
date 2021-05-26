module AuroraBootstrapParallelization
  class Runner
    def initialize( opts )
      @config = YAML.load_file( opts[ :config ] )[ "exporters" ]
      @is_cron_job = false
      if opts[ :cronjob ].nil?
        @is_cron_job = false
      else
        @is_cron_job = opts[ :cronjob ]
      end
    end

    def run!
      exporters.map( &:deploy )
    end

    protected

    def exporters
      if @is_cron_job
        @config.map do | env_config |
          CronjobExporter.new( env_config, @is_cron_job )
        end
      else
        @config.map do | env_config |
          JobExporter.new( env_config, @is_cron_job )
        end
      end
    end
  end
end
