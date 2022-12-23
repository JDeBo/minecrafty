module "auto_stopper" {
  source = "github.com/JDeBo/modules-ec2-auto-stopper.git"
  ec2_map = { "minecraft" = aws_instance.minecraft.id }
  use_case = "Minecraft"
}