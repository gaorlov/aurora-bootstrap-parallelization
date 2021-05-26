require 'yaml'
require 'erb'

module AuroraBootstrapParallelization
  class Exporter
    def initialize( config, is_cron_job )
      @name    = config[ "name" ]
      @env     = config[ "env" ]
      @version = config[ "version" ]
      @is_cron_job = to_b( is_cron_job )
    end

    def deploy
      # make file named tmp/#{self.name}-job.yml
      write_manifest
      kubectl_deploy
    end

    def manifest
      if @is_cron_job
        path = File.expand_path( "../../../templates/cronjob.yml", __FILE__ )
        @manifest ||= begin
          erb = ERB.new( File.read( path ) ).result( binding )
          YAML.load( erb ).tap do | manifest |
            manifest["spec"]["jobTemplate"][ "spec" ][ "template" ][ "spec" ][ "containers" ][0][ "env" ] = @env
          end
        end
      else
        path = File.expand_path( "../../../templates/job.yml", __FILE__ )
        @manifest ||= begin
          erb = ERB.new( File.read( path ) ).result( binding )
          YAML.load( erb ).tap do | manifest |
            manifest[ "spec" ][ "template" ][ "spec" ][ "containers" ][0][ "env" ] = @env
          end
        end
      end
    end

    def file_name
      if @is_cron_job
        @file_name ||= "#{@name}-cronjob.yml"
      else
        @file_name ||= "#{@name}-job.yml"
      end
      @file_name
    end
 
    def kubectl_deploy
      spawn "kubectl -n aurora-bootstrap create -f /tmp/#{file_name}"
    end

    def write_manifest
      file = File.open("/tmp/#{file_name}", 'w')
      file.write manifest.to_yaml
      file.close
      manifest.to_yaml
    end

    def to_b(string)
      case string
      when /^(TRUE|true|t|yes|y|1)$/i then true
      when /^(FALSE|false|f|no|n|0)$/i then false
      else raise "Cannot convert to boolean: #{string}"
      end
    end
  end
end
