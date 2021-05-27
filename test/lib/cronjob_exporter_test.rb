require 'test_helper'

class CronjobExporterTest < Minitest::Test
  def setup
    @config =   { "env" => [ { "name" => "DB_HOST", "value" => "localhost" },
                             { "name" => "EXPORT_BUCKET", "value" => "" } ],
                  "version" => "0.1.0.9",
                  "name" => "test-exporter" }
    @exporter = AuroraBootstrapParallelization::CronjobExporter.new @config
  end

  def test_manifest
    assert_equal( {"apiVersion"=>"batch/v1beta1", "kind"=>"CronJob", "metadata"=>{"name"=>"cron-job-test-exporter"}, "spec"=>{"schedule"=>"@daily", "jobTemplate"=>{"metadata"=>{"namespace"=>"aurora-bootstrap"}, "spec"=>{"backoffLimit"=>10, "completions"=>1, "parallelism"=>1, "template"=>{"metadata"=>{"annotations"=>{"cluster-autoscaler.kubernetes.io/safe-to-evict"=>"true", "iam.amazonaws.role"=>""}, "creationTimestamp"=>nil}, "spec"=>{"containers"=>[{"envFrom"=>[{"configMapRef"=>{"name"=>"configs"}}], "env"=>[{"name"=>"DB_HOST", "value"=>"localhost"}, {"name"=>"EXPORT_BUCKET", "value"=>""}], "image"=>"gaorlov/aurora-bootstrap:0.1.0.9", "imagePullPolicy"=>"Always", "name"=>"test-exporter", "resources"=>{"limits"=>{"cpu"=>"100m", "memory"=>"300Mi"}, "requests"=>{"cpu"=>"100m"}}, "terminationMessagePath"=>"/dev/termination-log", "terminationMessagePolicy"=>"File"}], "dnsConfig"=>{"options"=>[{"name"=>"ndots", "value"=>"1"}]}, "dnsPolicy"=>"ClusterFirst", "restartPolicy"=>"OnFailure", "schedulerName"=>"default-scheduler", "securityContext"=>{}, "terminationGracePeriodSeconds"=>30}}}}}},
                  @exporter.manifest )
  end

  def test_file_name
    assert_equal "test-exporter-cronjob.yml", @exporter.file_name
  end

  def test_write_manifest_with_env
    manifest = <<~YAML
    ---
    apiVersion: batch/v1beta1
    kind: CronJob
    metadata:
      name: cron-job-test-exporter
    spec:
      schedule: \"@daily\"
      jobTemplate:
        metadata:
          namespace: aurora-bootstrap
        spec:
          backoffLimit: 10
          completions: 1
          parallelism: 1
          template:
            metadata:
              annotations:
                cluster-autoscaler.kubernetes.io/safe-to-evict: 'true'
                iam.amazonaws.role: ''
              creationTimestamp:
            spec:
              containers:
              - envFrom:
                - configMapRef:
                    name: configs
                env:
                - name: DB_HOST
                  value: localhost
                - name: EXPORT_BUCKET
                  value: ''
                image: gaorlov/aurora-bootstrap:0.1.0.9
                imagePullPolicy: Always
                name: test-exporter
                resources:
                  limits:
                    cpu: 100m
                    memory: 300Mi
                  requests:
                    cpu: 100m
                terminationMessagePath: \"/dev/termination-log\"
                terminationMessagePolicy: File
              dnsConfig:
                options:
                - name: ndots
                  value: '1'
              dnsPolicy: ClusterFirst
              restartPolicy: OnFailure
              schedulerName: default-scheduler
              securityContext: {}
              terminationGracePeriodSeconds: 30
    YAML

        File.stub( :open, DummyFile.new ) do
            assert_output manifest do
              @exporter.write_manifest
            end
        end
  end
end