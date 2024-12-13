terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.8"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "aks-resource-group"
  location = "westus"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "akscluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v4"  # Moins de ressources
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

/*
resource "azapi_resource" "NodeRecordingRulesRuleGroup" {
  type      = "Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01"
  name      = "NodeRecordingRulesRuleGroup-${azurerm_kubernetes_cluster.k8s.name}"
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id
  body = jsonencode({
    "properties" : {
      "scopes" : [
        azurerm_kubernetes_cluster.k8s.id
      ],
      "clusterName" : azurerm_kubernetes_cluster.k8s.name,
      "interval" : "PT1M",
      "rules" : [
        {
          "name"        : "node_cpu_usage"
          "expr"        : "avg(rate(container_cpu_usage_seconds_total{job=\"kubernetes-cadvisor\", cluster=\"$cluster_name\"}[1m])) by (node)"
          "record"      : "avg_cpu_usage"
          "labels"      : {}
          "annotations": {
            "summary": "Average CPU usage per node"
          }
        },
        {
          "name"        : "node_memory_usage"
          "expr"        : "avg(container_memory_usage_bytes{job=\"kubernetes-cadvisor\", cluster=\"$cluster_name\"}) by (node)"
          "record"      : "avg_memory_usage"
          "labels"      : {}
          "annotations": {
            "summary": "Average memory usage per node"
          }
        }
      ]
    }
  })

  schema_validation_enabled = false
  ignore_missing_property   = false
}

resource "azapi_resource" "KubernetesRecordingRulesRuleGroup" {
  type      = "Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01"
  name      = "KubernetesRecordingRulesRuleGroup-${azurerm_kubernetes_cluster.k8s.name}"
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id
  body = jsonencode({
    "properties" : {
      "scopes" : [
        azurerm_kubernetes_cluster.k8s.id
      ],
      "clusterName" : azurerm_kubernetes_cluster.k8s.name,
      "interval" : "PT1M",
      "rules" : [
        {
          "name"        : "cpu_usage_pod"
          "expr"        : "avg(rate(container_cpu_usage_seconds_total{job=\"kubernetes-pod-cadvisor\", cluster=\"$cluster_name\"}[1m])) by (pod, namespace)"
          "record"      : "avg_cpu_usage_per_pod"
          "labels"      : {}
          "annotations": {
            "summary": "Average CPU usage per pod"
          }
        },
        {
          "name"        : "memory_usage_pod"
          "expr"        : "avg(container_memory_usage_bytes{job=\"kubernetes-pod-cadvisor\", cluster=\"$cluster_name\"}) by (pod, namespace)"
          "record"      : "avg_memory_usage_per_pod"
          "labels"      : {}
          "annotations": {
            "summary": "Average memory usage per pod"
          }
        }
      ]
    }
  })

  schema_validation_enabled = false
  ignore_missing_property   = false
}

# Webhook Alertmanager Configuration
resource "azapi_resource" "alertmanager_configuration" {
  type      = "Microsoft.AlertsManagement/alertRules@2023-03-01"
  name      = "cpu-memory-alert-webhook"
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id
  body = jsonencode({
    "properties" : {
      "enabled" : true,
      "condition" : {
        "allOf" : [
          {
            "metricName" : "avg_cpu_usage"
            "operator"   : "GreaterThan"
            "threshold"  : 80
          },
          {
            "metricName" : "avg_memory_usage"
            "operator"   : "GreaterThan"
            "threshold"  : 80
          }
        ]
      },
      "action" : {
        "webhook" : {
          "uri" : "https://discord.com/api/webhooks/1316957765201166397/qX_Rdnx4L3lMUjZkMYDMGeHteoRTqyxFmFiVgZtET2GCvzeAsmW8_hAc9cgvGcr5YX3I"
          "headers" : {
            "Content-Type" : "application/json"
          },
          "method" : "POST"
        }
      }
    }
  })

  schema_validation_enabled = false
  ignore_missing_property   = false
}
*/

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "aks_cluster_location" {
  value = azurerm_kubernetes_cluster.k8s.location
}
