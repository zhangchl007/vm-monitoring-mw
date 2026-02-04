# the environment variables env_prefix is critical for the different AKS clusters
env_prefix               = "shein-test"
location                 = "West US 3"
kube_vnet_name           = "vnet"
kube_version_prefix      = "1.33"
kube_resource_group_name = "rg"
cluster_name             = "test-aks-1"
nodepool_nodes_count     = 2
nodepool_vm_size         = "Standard_D2s_v3"
network_dns_service_ip   = "172.15.0.10"
network_service_cidr     = "172.15.0.0/24"
acr_name                 = "sheinacr01"
acr_resource_group       = "shein-test-rg"
address_space            = ["172.15.0.0/16"]
username                 = "azureuser"
ssh_public_key           = "~/.ssh/id_rsa.pub"
subnets = [
  {
    name             = "node-subnet"
    address_prefixes = ["172.15.1.0/24"]
    delegation       = ""
  },
  {
    name             = "pod-subnet"
    address_prefixes = ["172.15.2.0/24"]
    delegation       = "Microsoft.ContainerService/managedClusters"
  },
  {
    name             = "appgw-subnet"
    address_prefixes = ["172.15.3.0/24"]
    delegation       = "Microsoft.ServiceNetworking/trafficControllers"
  },
  {
    name             = "ingress-subnet"
    address_prefixes = ["172.15.4.0/24"]
    delegation       = ""
  },
  {
    name             = "mysql-subnet"
    address_prefixes = ["172.15.5.0/24"]
    delegation       = "Microsoft.DBforMySQL/flexibleServers"
  },
  {
    name             = "privateendpoint-subnet"
    address_prefixes = ["172.15.6.0/24"]
    delegation       = ""
  }
]

merge_vmselect_vminsert_when_sparse = true

vm_nsg_rules = [
  {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "AllowRDP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "AllowvmstorageNameServer"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9876"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "AllowvmstorageBroker"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10911"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "AllowvmstorageBrokerHA"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10912"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "AllowvmstorageConsole"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]

## Virtual Machines (Batch Configuration)
vms = {
  vmauth01 = {
    vm_name             = "vmauth01"
    vm_size             = "Standard_D4s_v5"
    subnet_name         = "node-subnet"
    admin_username      = "azureuser"
    ssh_public_key_path = "~/.ssh/id_rsa.pub"
    os_type             = "linux"
    enable_public_ip    = true
    roles               = ["vmauth"]
    tags = {
      Purpose = "BastionHost"
    }
  }

  vmstorage01 = {
    vm_name             = "vmstorage01"
    vm_size             = "Standard_D4s_v5"
    subnet_name         = "node-subnet"
    admin_username      = "azureuser"
    ssh_public_key_path = "~/.ssh/id_rsa.pub"
    os_type             = "linux"
    enable_public_ip    = true
    roles               = ["vmstorage"]
    tags = {
      Purpose = "MessageBroker"
    }
  }

  vmstorage02 = {
    vm_name             = "vmstorage02"
    vm_size             = "Standard_D4s_v5"
    subnet_name         = "node-subnet"
    admin_username      = "azureuser"
    ssh_public_key_path = "~/.ssh/id_rsa.pub"
    os_type             = "linux"
    enable_public_ip    = true
    roles               = ["vmstorage"]
    tags = {
      Purpose = "MessageBroker"
    }
  }

  vminsert01 = {
    vm_name             = "vminsert01"
    vm_size             = "Standard_D4s_v5"
    subnet_name         = "node-subnet"
    admin_username      = "azureuser"
    ssh_public_key_path = "~/.ssh/id_rsa.pub"
    os_type             = "linux"
    enable_public_ip    = true
    roles               = ["vminsert"]
    tags = {
      Purpose = "MessageBroker"
    }
  }

  vminsert02 = {
    vm_name             = "vminsert02"
    vm_size             = "Standard_D4s_v5"
    subnet_name         = "node-subnet"
    admin_username      = "azureuser"
    ssh_public_key_path = "~/.ssh/id_rsa.pub"
    os_type             = "linux"
    enable_public_ip    = true
    roles               = ["vminsert"]
    tags = {
      Purpose = "MessageBroker"
    }
  }

  grafana01 = {
    vm_name             = "grafana01"
    vm_size             = "Standard_D4s_v5"
    subnet_name         = "node-subnet"
    admin_username      = "azureuser"
    ssh_public_key_path = "~/.ssh/id_rsa.pub"
    os_type             = "linux"
    enable_public_ip    = true
    roles               = ["grafana"]
    tags = {
      Purpose = "MessageBroker"
    }
  }

  vmagent01 = {
    vm_name             = "vmagent01"
    vm_size             = "Standard_D2s_v5"
    subnet_name         = "node-subnet"
    admin_username      = "azureuser"
    ssh_public_key_path = "~/.ssh/id_rsa.pub"
    os_type             = "linux"
    enable_public_ip    = false
    roles               = ["vmagent"]
    tags = {
      Purpose = "MetricsCollector"
    }
  }
}


