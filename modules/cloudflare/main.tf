# Get the zone ID based on name of our zone

data "cloudflare_zone" "cloudflare" {
  name = var.zone_name
}

resource "cloudflare_zone_settings_override" "cloudflare" {
  zone_id = data.cloudflare_zone.cloudflare.id
  settings {
    always_use_https = "on"
    brotli           = "on"
    min_tls_version  = "1.2"
    ssl              = "full"
    tls_1_3          = "on"
  }
}