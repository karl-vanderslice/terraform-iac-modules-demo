variable "domain_name" {
  default     = null
  type        = string
  description = "Domain name to provision records against.  Needs to exist in Cloudflare."
}

variable "environment_name" {
  default     = "dev"
  type        = string
  description = "Environment (sub-domain) to use, ie dev.foo.io"
}

variable "tags" {
  default     = {}
  type        = map(any)
  description = "List of tags to add to the created resources."
}
