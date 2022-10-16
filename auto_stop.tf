module "auto_stopper" {
  source = "github.com/JDeBo/modules-ec2-auto-stopper.git"
  ec2_map = { "steam" = aws_instance.steam.id }
  use_case = "SteamServer"
}