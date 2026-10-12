# Values for the PROD environment.
#
# Always paired with the prod workspace:
#
#   terraform workspace select prod
#   terraform apply -var-file=envs/prod.tfvars
#
# main.tf refuses to plan if the workspace and this file disagree.
#
# Read this file next to dev.tfvars: the diff between them IS the definition
# of how the two environments differ. Keep that diff short and deliberate.

environment = "prod"

# REQUIRED — same project, same internal network as dev. Two VMs in one
# cPouta project, not two projects.
network_name = "project_2020730"

# REQUIRED — same registry namespace as dev. Both VMs pull from the same
# images; different images per environment would make dev's green test
# result meaningless.
ghcr_owner = "tobias-e-e"

# Open to the whole internet, like dev — and that is a known weakness, not a
# choice. The deploy jobs SSH in from GitHub-hosted runners, whose addresses
# change from run to run, so a /32 here would lock out your own pipeline
# (deploy-prod times out on port 22). Prod's SSH is protected by the key
# alone. That is the price of the push model: a pull model (an agent on the
# VM pulling its desired state) or a self-hosted runner with a fixed address
# would let you close this. The app port is open in both environments either
# way — it is a public web app.
ssh_allowed_cidr = "0.0.0.0/0"

# Identical to dev. See the note in dev.tfvars: a prod-shaped dev is the
# only kind worth having.
flavor_name = "standard.small"
