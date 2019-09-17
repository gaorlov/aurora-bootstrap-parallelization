require 'test_helper'

class RunnerTest < Minitest::Test
  def setup
    @runner = AuroraBootstrapParallelization::Runner.new( config: File.expand_path( "../../config.yml", __FILE__ ) )
  end

  def test_runner
    manifests = <<-YAML
---
- apiVersion: batch/v1
  kind: Job
  metadata:
    labels:
      app: test-1
      name: test-1
    name: test-1
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
          app: test-1
          job-name: test-1
          name: test-1
      spec:
        containers:
        - envFrom:
          - configMapRef:
              name: configs
          - secretRef:
              name: secrets
          env:
          - name: EPOCH_TIMESTAMP
            value: 1568059200
          - name: EXPORT_BUCKET
            value: s3//:bukkit-1
          - name: DB_HOST
            value: localhost-1
          image: gaorlov/aurora-bootstrap:0.1.0.9
          imagePullPolicy: Always
          name: test-1
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
- apiVersion: batch/v1
  kind: Job
  metadata:
    labels:
      app: test-2
      name: test-2
    name: test-2
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
          app: test-2
          job-name: test-2
          name: test-2
      spec:
        containers:
        - envFrom:
          - configMapRef:
              name: configs
          - secretRef:
              name: secrets
          env:
          - name: EPOCH_TIMESTAMP
            value: 1568059200
          - name: EXPORT_BUCKET
            value: s3//:bukkit-2
          - name: DB_HOST
            value: localhost-2
          image: gaorlov/aurora-bootstrap:0.1.0.9
          imagePullPolicy: Always
          name: test-2
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
    
    assert_equal manifests, @runner.send( :exporters ).map( &:manifest ).to_yaml
  end
end