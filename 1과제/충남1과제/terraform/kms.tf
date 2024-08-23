resource "aws_kms_key" "eks_secret_cmk" {
  
}

resource "aws_kms_alias" "eks_secret_cmk_alias" {
  name = "alias/eks_secret_cmk"
  target_key_id = aws_kms_key.eks_secret_cmk.id
}