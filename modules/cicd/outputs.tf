output "bucket"        { value = aws_s3_bucket.artifacts.bucket }
output "pipeline_name" { value = aws_codepipeline.pipeline.name }
