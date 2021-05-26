require 'yaml'
require 'erb'

module AuroraBootstrapParallelization
  class Exporter
    def initialize( config, is_cron_job )
      @name    = config[ "name" ]
      @env     = config[ "env" ]
      @version = config[ "version" ]
      @is_cron_job = is_cron_job
    end

    def deploy
      # make file named tmp/#{self.name}-job.yml
      write_manifest
      kubectl_deploy
    end

    def manifest
      nil
    end

    def file_name
      nil
    end
 
    def kubectl_deploy
      spawn "kubectl -n aurora-bootstrap create -f /tmp/#{file_name}"
    end

    def write_manifest
      file = File.open("/tmp/#{file_name}", 'w')
      file.write manifest.to_yaml
      file.close
    end
  end
end
