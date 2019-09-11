module AuroraBootstrapParallelization
  class Runner
    def initialize( opts )
      @config = Yaml.load_file( opts[ :config ] )
    end

    def run!
      exporters.map( &:deploy )
    end

    protected

    def exporters
      @config.map do | env_config |
        Exporter.new( env_config )
      end
    end
  end
end
