require 'yaml'
require 'erb'

module AuroraBootstrapParallelization
  class Exporter
    def initialize( config )
      @name    = config[ "name" ]
      @env     = config[ "env" ]
      @version = config[ "version" ]
    end

    def deploy
      # make file named tmp/#{self.name}-job.yml
      write_manifest
      kubectl_deploy
    end

    def manifest
      @manifest ||= begin
        path = File.expand_path( "../../../templates/job.yml", __FILE__ )
        erb = ERB.new( File.read( path ) ).result( binding )
        YAML.load( erb ).tap do | manifest |
          manifest[ "spec" ][ "template" ][ "spec" ][ "containers" ][0][ "env" ] = @env
        end
      end
    end

    def file_name
      @file_name ||= "#{@name}-job.yml"
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