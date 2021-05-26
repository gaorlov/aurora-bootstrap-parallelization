require 'yaml'
require 'erb'

module AuroraBootstrapParallelization
    class CronjobExporter < Exporter
      def initialize( config, is_cron_job )
        super(config, true)
      end

      def manifest
        path = File.expand_path( "../../../templates/cronjob.yml", __FILE__ )
        @manifest ||= begin
          erb = ERB.new( File.read( path ) ).result( binding )
          YAML.load( erb ).tap do | manifest |
            manifest["spec"]["jobTemplate"][ "spec" ][ "template" ][ "spec" ][ "containers" ][0][ "env" ] = @env
          end
        end
      end
  
      def file_name
        @file_name ||= "#{@name}-cronjob.yml"
      end
    end
end