# module "auto_stopper" {
#   source = "github.com/JDeBo/modules-ec2-auto-stopper.git"
#   ec2_map = { "minecraft" = aws_spot_instance_request.main.spot_instance_id }
#   use_case = "Minecraft"
# }