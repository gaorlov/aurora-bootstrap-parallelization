require 'yaml'
require 'erb'

module AuroraBootstrapParallelization
  # for scheduled run of aurora-bootstrap script
  class CronjobExporter < Exporter

    def initialize( config )
      super( config )
      @type = 'cronjob'
    end

    def env_path
      ["spec", "jobTemplate", "spec", "template", "spec", "containers"]
    end
  end
end
