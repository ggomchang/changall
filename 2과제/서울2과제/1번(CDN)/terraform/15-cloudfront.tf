module "cdn" {
  source = "./modules/cloudfront/distribution"

  oac_name           = "cloudfront-s3-oac"
  bucket_domain_name = module.bucket.bucket_domain_name
  bucket_id          = module.bucket.bucket_id
  bucket             = module.bucket.bucket
  default_root_object = "index.html"
  resizing_lambda_arn = "${module.resizing_lambda_function.function_arn}:${module.resizing_lambda_function.function_version}"
}
