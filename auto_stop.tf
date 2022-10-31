module "auto_stopper" {
  source = "github.com/JDeBo/modules-ec2-auto-stopper.git"
  ec2_map = { "steam" = "changeme" }
  use_case = "SteamServer"
}