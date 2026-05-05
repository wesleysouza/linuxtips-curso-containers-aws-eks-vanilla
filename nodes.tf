resource "aws_eks_node_group" "main" {
  cluster_name = aws_eks_cluster.main.id
  node_group_name = aws_eks_cluster.main.id

  node_role_arn = aws_iam_role.eks_nodes_role.arn
  instance_types = var.nodes_instance_sizes

  subnet_ids = data.aws_ssm_parameter.pod_subnets[*].value
  
  scaling_config {
    desired_size = lookup(var.auto_scale_options, "desired")
    min_size = lookup(var.auto_scale_options, "min")
    max_size = lookup(var.auto_scale_options, "max")
  }

  labels = {
    "ingress/ready" = true
  }

  depends_on = [ 
    kubernetes_config_map.aws-auth
    ]

  lifecycle {
    ignore_changes = [ 
        scaling_config[0].desired_size
     ]
  }

  timeouts {
    create = "60m"
    update = "2h"
    delete = "2h"
  }
}