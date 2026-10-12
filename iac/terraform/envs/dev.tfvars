# Values for the DEV environment.
#
# Always paired with the dev workspace:
#
#   terraform workspace select dev
#   terraform apply -var-file=envs/dev.tfvars
#
# main.tf refuses to plan if the workspace and this file disagree.
#
# Unlike terraform.tfvars, this file IS committed — it contains no secrets,
# and the whole point of the two-environment setup is that the difference
# between dev and prod is visible in git. If you have to SSH somewhere to
# find out how prod differs from dev, you do not have two environments, you
# have two mysteries.

environment = "dev"

# REQUIRED — your project's internal network name (`openstack network list`).
network_name = "project_2020730"

# REQUIRED — GHCR namespace publishing the two images (your GitHub username
# or org). Must match .github/workflows/publish-images.yml.
ghcr_owner = "tobias-e-e"

# Dev is reachable for debugging: SSH from anywhere. Fine for a throwaway
# machine with no real data on it. prod.tfvars has to do the same, for a
# worse reason - read the comment there.
ssh_allowed_cidr = "0.0.0.0/0"

# Same flavor as prod ON PURPOSE. It is tempting to save quota by running a
# smaller dev VM, and it is exactly how you get "works on dev, OOM-kills on
# prod". Dev is only useful as a prediction of prod to the extent that it is
# shaped like prod — differences should be things you chose, not things you
# drifted into.
flavor_name = "standard.small"
