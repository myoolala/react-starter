output "lb_endpoint" {
    value = module.fargate_service.cname_target
}