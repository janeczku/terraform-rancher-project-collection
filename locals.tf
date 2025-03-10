locals {
  tags = {
    terraform        = "true"
    terraform_code   = "https://github.com/rancher/terraform-rancher2-project"
    terraform_module = "terraform-rancher2-project"
  }

  project_info = {
    prefix_resource   = !var.disable_prefix ? "${var.project.name}-" : ""
    cluster_id        = var.project.cluster_id
    disable_prefix    = var.disable_prefix
    wait_for_catalogs = var.wait_for_catalogs
    name              = var.project.name
    role_bindings = var.project.role_bindings != null ? flatten([for role_k, role_v in var.project.role_bindings : {
      name = !var.disable_prefix ? "${var.project.name}-${role_k}" : role_k
      data = { for conf_k, conf_v in role_v : conf_k => conf_v }
    }]) : []
    resource_quota = var.project.project_limit != null && var.project.namespace_default_limit != null ? length(var.project.project_limit) > 0 && length(var.project.namespace_default_limit) > 0 ? [{
      project_limit           = var.project.project_limit
      namespace_default_limit = var.project.namespace_default_limit
    }] : [] : []
    container_resource_limit = var.project.container_resource_limit != null ? length(var.project.container_resource_limit) > 0 ? [{
      limit = var.project.container_resource_limit
    }] : [] : []
  }

  app_list = flatten([for app_k, app_v in var.apps : [{
    name          = "${local.project_info.prefix_resource}${app_k}"
    namespace     = "${local.project_info.prefix_resource}${app_v.namespace}"
    repo_name     = app_v.repo_name
    chart_name    = app_v.chart_name
    chart_version = app_v.chart_version
    values        = app_v.values
  }]])

  config_map_list = flatten([for conf_k, conf_v in var.config_maps : {
    name      = "${local.project_info.prefix_resource}${conf_k}"
    namespace = "${local.project_info.prefix_resource}${conf_v.namespace}"
    data      = { for k, v in conf_v.data : k => v }
  }])

  namespace_list = flatten([for k, v in var.namespaces : {
    name = "${local.project_info.prefix_resource}${k}"
    resource_quota = v.limit != null ? length(v.limit) > 0 ? [{
      limit = v.limit
    }] : [] : []
    container_resource_limit = v.container_resource_limit != null ? length(v.container_resource_limit) > 0 ? [{
      limit = v.container_resource_limit
    }] : [] : []
  }])

  secret_list = flatten([for sec_k, sec_v in var.secrets : {
    name      = "${local.project_info.prefix_resource}${sec_k}"
    namespace = "${local.project_info.prefix_resource}${sec_v.namespace}"
    type      = sec_v.type
    data      = { for k, v in sec_v.data : k => v }
  }])
}
