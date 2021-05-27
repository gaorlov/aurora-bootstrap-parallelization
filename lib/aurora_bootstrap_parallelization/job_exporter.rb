require 'yaml'
require 'erb'
require 'ruby_dig'

module AuroraBootstrapParallelization
  # for one time run of aurora-bootstrap script
  class JobExporter < Exporter
    
    def initialize( config )
      super( config )
      @type = 'job'
    end

    def env_path
      ["spec", "template", "spec", "containers"]
    end

  end
end
