# Flexible Raft benchmark for TiKV

## Create TiKV cluster

Before creating cluster resources delete any existing ones

### Steps to delete any existing resources created for benchmark

- Delete NetworkChaos
  `kubectl delete networkchaos network-chaos-delay -n chaos-testing`

- Check for existing TiKV cluster
  `kubectl get tikvcluster -n default`

- Delete TiKV cluster
  `kubectl delete tikvcluster <cluster_name> -n default`

- Check for existing PVC (block storage)
  `kubectl get pvc --selector=app.kubernetes.io/instance=test-cluster -n default`

- Delete existing PVCs
  `kubectl delete pvc --selector=app.kubernetes.io/instance=test-cluster -n default`

### Steps to recreate cluster

- Apply TiKV cluster manifest
  `kubectl apply -f ./ycsb/tikv-cluster-baseline.yaml`

- This will launch PD pods and TiKV pods as a statefulsets with PVC bound to it
  Check if all the resources are up
  `kubectl get pods --selector=app.kubernetes.io/instance=test-cluster`

- Apply network chaos to simulate network latencies
  `kubectl apply -f ./ycsb/network-chaos-delay.yaml`
  `.spec.value` defines how much pods you want to add delay on

### Run YCSB Benchmark

- Load BenchmarkF
  `./bin/go-ycsb load tikv \
    -P $GOPATH/src/github.com/pingcap/go-ycsb/workloads/workloadf \
    -p tikv.pd="test-cluster-pd:2379" -p tikv.type="raw" \
    -p tikv.conncount=64 -p tikv.batchsize=64 \
    -p operationcount=100000 -p recordcount=100000 \
    -p threadcount=100`

- Run BenchmarkF
  `./bin/go-ycsb run tikv \
    -P $GOPATH/src/github.com/pingcap/go-ycsb/workloads/workloadf \
    -p tikv.pd="test-cluster-pd:2379" -p tikv.type="raw" \
    -p operationcount=100000 -p recordcount=100000 \
    -p threadcount=100`
