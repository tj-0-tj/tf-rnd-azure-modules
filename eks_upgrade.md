# AKS Upgrade process

Part of the AKS cluster lifecycle involves performing periodic upgrades to the latest Kubernetes version. It's important you apply the latest security releases, or upgrade to get the latest features. This article shows you how to check for, configure, and apply upgrades to the AKS cluster manually or via github action.

## Requirements

- If you're using Azure CLI, this article requires that you're running the Azure CLI version 2.34.1 or later. Run az --version to find the version.

## Upgrade AKS version

When you upgrade a supported AKS cluster, Kubernetes minor versions can't be skipped. You must perform all upgrades sequentially by major version number. For example, upgrades between 1.14.x -> 1.15.x or 1.15.x -> 1.16.x are allowed, however 1.14.x -> 1.16.x isn't allowed.

Skipping multiple versions can only be done when upgrading from an unsupported version back to a supported version. For example, an upgrade from an unsupported 1.10.x -> a supported 1.15.x can be completed if available. When performing an upgrade from an unsupported version that skips two or more minor versions, the upgrade is performed without any guarantee of functionality and is excluded from the service-level agreements and limited warranty. If your version is significantly out of date, we recommend you recreate your cluster.

### Manual upgrade process

During the cluster upgrade process, AKS performs the following operations:

- Add a new buffer node (or as many nodes as configured in max surge) to the cluster that runs the specified Kubernetes version.
- Cordon and drain one of the old nodes to minimize disruption to running applications. If you're using max surge, it cordons and drains as many nodes at the same time as the number of buffer nodes specified.
- When the old node is fully drained, it's reimaged to receive the new version and becomes the buffer node for the following node to be upgraded.
- This process repeats until all nodes in the cluster have been upgraded.
- At the end of the process, the last buffer node is deleted, maintaining the existing agent node count and zone balance.

IMPORTANT
Ensure that any PodDisruptionBudgets (PDBs) allow for at least one pod replica to be moved at a time otherwise the drain/evict operation will fail. If the drain operation fails, the upgrade operation will fail by design to ensure that the applications are not disrupted. Please correct what caused the operation to stop (incorrect PDBs, lack of quota, and so on) and re-try the operation.

#### Check available versions
To find details of available aks upgrades:
```azurecli-interactive
az aks get-versions -l uksouth -o table
```

#### Check for available AKS cluster upgrades

You can check which Kubernetes releases are available for your cluster using the "az aks get-upgrades" command.

```azurecli-interactive
az aks get-upgrades --resource-group myResourceGroup --name myAKSCluster --output table
```

#### Upgrading cluster

- Upgrade the cluster using the "az aks upgrade" command
    ```azurecli-interactive
    az aks upgrade \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --kubernetes-version KUBERNETES_VERSION
    ```

- To confirm the upgrade was successful using the az aks show command.
    ```azurecli-interactive
    az aks show --resource-group myResourceGroup --name myAKSCluster --output table
    ```

##### View the upgrade events

When you upgrade your cluster, the following Kubernetes events may occur on each node:

* **Surge**: Creates a surge node.
* **Drain**: Evicts pods from the node. Each pod has a 30-second timeout to complete the eviction.
* **Update**: Update of a node succeeds or fails.
* **Delete**: Deletes a surge node.

Use `kubectl get events` to show events in the default namespaces while running an upgrade. For example:

```azurecli-interactive
kubectl get events 
```

The following example output shows some of the above events listed during an upgrade.

```output
...
default 2m1s Normal Drain node/aks-nodepool1-96663640-vmss000001 Draining node: [aks-nodepool1-96663640-vmss000001]
...
default 9m22s Normal Surge node/aks-nodepool1-96663640-vmss000002 Created a surge node [aks-nodepool1-96663640-vmss000002 nodepool1] for agentpool %!s(MISSING)
...
```
##### Customize node surge upgrade

> [!IMPORTANT]
>
> Node surges require subscription quota for the requested max surge count for each upgrade operation. For example, a cluster that has five node pools, each with a count of four nodes, has a total of 20 nodes. If each node pool has a max surge value of 50%, additional compute and IP quota of 10 nodes (2 nodes * 5 pools) is required to complete the upgrade.
>
> The max surge setting on a node pool is persistent.  Subsequent Kubernetes upgrades or node version upgrades will use this setting. You may change the max surge value for your node pools at any time. For production node pools, the recommended max-surge setting is 33%.
>

By default, AKS configures upgrades to surge with one extra node. A default value of one for the max surge settings enables AKS to minimize workload disruption by creating an extra node before the cordon/drain of existing applications to replace an older versioned node. The max surge value can be customized per node pool to enable a trade-off between upgrade speed and upgrade disruption. When you increase the max surge value, the upgrade process completes faster. If you set a large value for max surge, you might experience disruptions during the upgrade process.

For example, a max surge value of *100%* provides the fastest possible upgrade process (doubling the node count) but also causes all nodes in the node pool to be drained simultaneously. You might want to use a higher value such as this for testing environments. For production node pools, it is recommended to set a `max_surge` setting of *33%*.

AKS accepts both integer values and a percentage value for max surge. An integer such as *5* indicates five extra nodes to surge. A value of *50%* indicates a surge value of half the current node count in the pool. Max surge percent values can be a minimum of *1%* and a maximum of *100%*. A percent value is rounded up to the nearest node count. If the max surge value is higher than the required number of nodes to be upgraded, the number of nodes to be upgraded is used for the max surge value.

During an upgrade, the max surge value can be a minimum of *1* and a maximum value equal to the number of nodes in your node pool. You can set larger values, but the maximum number of nodes used for max surge isn't higher than the number of nodes in the pool at the time of upgrade.

###### Set max surge values

Set max surge values for new or existing node pools using the following commands:

```azurecli-interactive
# Set max surge for a new node pool
az aks nodepool add -n mynodepool -g MyResourceGroup --cluster-name MyManagedCluster --max-surge 33%

# Update max surge for an existing node pool 
az aks nodepool update -n mynodepool -g MyResourceGroup --cluster-name MyManagedCluster --max-surge 5
```