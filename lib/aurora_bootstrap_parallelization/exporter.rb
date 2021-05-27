require 'yaml'
require 'erb'

module AuroraBootstrapParallelization
  # Load config file and create k8s job
  class Exporter

    def initialize( config )
      @name    = config[ "name" ]
      @env     = config[ "env" ]
      @version = config[ "version" ]
    end

    def deploy
      write_manifest
      kubectl_deploy
    end

    def manifest
      @manifest ||= begin
        erb = ERB.new( File.read( template_path ) ).result( binding )
        YAML.load( erb ).tap do | manifest |
          manifest.dig( *env_path )[0]["env"] = @env
        end
      end
    end

    def template_path
      File.expand_path( "../../../templates/#{@type}.yml", __FILE__ )
    end

    def file_name
      @file_name ||= "#{@name}-#{@type}.yml"
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
