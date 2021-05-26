require 'test_helper'

class ExporterTest < Minitest::Test
  def setup
    @config =   { "env" => [ { "name" => "DB_HOST", "value" => "localhost" },
                             { "name" => "EXPORT_BUCKET", "value" => "" } ],
                  "version" => "0.1.0.9",
                  "name" => "test-exporter" }
    @is_cron_job = false
    @exporter = AuroraBootstrapParallelization::JobExporter.new @config, @is_cron_job
  end

  def test_manifest
    assert_equal( {"apiVersion"=>"batch/v1", "kind"=>"Job", "metadata"=>{"labels"=>{"app"=>"test-exporter", "name"=>"test-exporter"}, "name"=>"test-exporter", "namespace"=>"aurora-bootstrap"}, "spec"=>{"backoffLimit"=>10, "completions"=>1, "parallelism"=>1, "template"=>{"metadata"=>{"annotations"=>{"cluster-autoscaler.kubernetes.io/safe-to-evict"=>"true", "iam.amazonaws.role"=>""}, "creationTimestamp"=>nil, "labels"=>{"app"=>"test-exporter", "job-name"=>"test-exporter", "name"=>"test-exporter"}}, "spec"=>{"containers"=>[{"envFrom"=>[{"configMapRef"=>{"name"=>"configs"}}], "env"=>[{"name"=>"DB_HOST", "value"=>"localhost"}, {"name"=>"EXPORT_BUCKET", "value"=>""}], "image"=>"gaorlov/aurora-bootstrap:0.1.0.9", "imagePullPolicy"=>"Always", "name"=>"test-exporter", "resources"=>{"limits"=>{"cpu"=>"100m", "memory"=>"300Mi"}, "requests"=>{"cpu"=>"100m"}}, "terminationMessagePath"=>"/dev/termination-log", "terminationMessagePolicy"=>"File"}], "dnsConfig"=>{"options"=>[{"name"=>"ndots", "value"=>"1"}]}, "dnsPolicy"=>"ClusterFirst", "restartPolicy"=>"OnFailure", "schedulerName"=>"default-scheduler", "securityContext"=>{}, "terminationGracePeriodSeconds"=>30}}}},
                  @exporter.manifest )
  end

  def test_file_name
    assert_equal "test-exporter-job.yml", @exporter.file_name
  end

  def test_write_manifest
    manifest = <<~YAML
      ---
      apiVersion: batch/v1
      kind: Job
      metadata:
        labels:
          app: test-exporter
          name: test-exporter
        name: test-exporter
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
            labels:
              app: test-exporter
              job-name: test-exporter
              name: test-exporter
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
              terminationMessagePath: "/dev/termination-log"
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
      # assert_output is flaky
      @exporter.write_manifest
      assert_equal manifest, @exporter.instance_variable_get(:@manifest).to_yaml
    end
  end
end