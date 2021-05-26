require 'yaml'
require 'erb'

module AuroraBootstrapParallelization
    class JobExporter < Exporter
      def initialize( config, is_cron_job )
        super(config, false)
      end

      def manifest
        path = File.expand_path( "../../../templates/job.yml", __FILE__ )
        @manifest ||= begin
        erb = ERB.new( File.read( path ) ).result( binding )
            YAML.load( erb ).tap do | manifest |
            manifest[ "spec" ][ "template" ][ "spec" ][ "containers" ][0][ "env" ] = @env
            end
        end
      end
  
      def file_name
        @file_name ||= "#{@name}-job.yml"
      end
    end
end