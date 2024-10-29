# Project Structure

```
aws-k3s-cluster/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── ansible/
│   ├── install_k3s_master.yml
│   ├── install_k3s_workers.yml
│   └── inventory.ini  # Generated automatically from Terraform
└── .github/
    └── workflows/
        └── k3s_cluster.yml
```