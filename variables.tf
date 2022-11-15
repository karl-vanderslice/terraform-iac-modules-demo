variable "environment_name" {
  default     = "dev"
  type        = string
  description = "Name of the environment to provision.  Resources will use this for naming."
}

variable "cloudflare_zone_name" {
  default     = null
  type        = string
  description = "Zone name to provision records and configure security settings for."
}

variable "tags" {
  default = {
    "costCode" = "123456"
    "foo"      = "bar"
  }
  type        = map(any)
  description = "Map of tags to add to created resources."
}