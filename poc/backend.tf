terraform {
    backend "s3" {
        bucket          = "keren-poc"
        key             = "wordpress-poc/terraform.tfstate"
        region          = "eu-west-1"
        profile         = "sandbox-keren"
    }
}

