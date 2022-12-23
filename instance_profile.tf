resource "aws_iam_instance_profile" "this" {
  name = "SSMForEC2"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name = "SSMForEC2"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "ec2_s3" {
  statement {
    sid       = "EC2CopyFromS3"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.world_files.arn,"${aws_s3_bucket.world_files.arn}/*"]
  }
}

resource "aws_iam_policy" "ec2_s3" {
  path        = "/"
  description = "EC2UseS3-${local.use_case}"
  policy      = data.aws_iam_policy_document.ec2_s3.json
}

resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ec2_s3.arn
}

resource "aws_iam_role_policy_attachment" "core" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "patch" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}