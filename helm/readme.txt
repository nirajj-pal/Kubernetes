# validate
helm lint .

# render yaml locally
helm template test-release .

# install
helm install test-release .

# install or upgrade
helm upgrade --install test-release .

# check release
helm status test-release
helm list -A
helm list -n prod

# see applied values and manifest
helm get values test-release -n prod
helm get manifest test-release -n prod

# history and rollback
helm history test-release -n prod
helm rollback test-release 1 -n prod

# remove release
helm uninstall test-release -n default
