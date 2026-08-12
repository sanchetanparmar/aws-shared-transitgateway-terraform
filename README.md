# aws-shared-tgw-terraform

Terraform template for a hub-and-spoke network: one **shared** account owns an AWS
Transit Gateway (TGW), and one or more **spoke** environments (e.g. `dev`) attach to
it by accepting the TGW as a shared resource via AWS RAM (Resource Access Manager).

## What it does

- **`env/shared`** — creates the hub VPC and the Transit Gateway, and shares the TGW
  with one or more spoke AWS accounts via `ram_principals`.
- **`env/dev`** — creates a spoke VPC, accepts the RAM share for the TGW from the
  shared account, and attaches its own VPC to that TGW.

Each environment is a separate Terraform root module with its own S3 backend/state.
Add more spoke environments by copying `env/dev` (e.g. to `env/staging`, `env/prod`)
and adjusting its `vars.tf`.

## Layout

```
env/
├── shared/            # hub account: VPC + Transit Gateway + RAM share
│   ├── providers.tf   # backend + aws provider
│   ├── vars.tf        # input variables (project, vpc_cidr, tgw_name, ...)
│   ├── vpc.tf         # hub VPC
│   ├── tgw.tf         # Transit Gateway + RAM principals to share with
│   └── locals.tf      # remote state data source (currently unused downstream)
└── dev/               # spoke account: VPC + RAM accept + TGW attachment
    ├── providers.tf   # backend + two aws providers: default (assumed role
    │                  # into this account) and `aws.shared` (the hub account)
    ├── vars.tf         # input variables (project, account_id, vpc_cidr, ...)
    ├── vpc.tf          # spoke VPC
    ├── tgw_connections.tf  # RAM share/accept + TGW VPC attachment
    └── outputs.tf
```

### Why two AWS providers in `env/dev`?

The Transit Gateway and its RAM resource share live in the **shared** account, not
the spoke account. `tgw_connections.tf` uses `provider = aws.shared` for the RAM
resources (`aws_ram_resource_share`, `aws_ram_principal_association`,
`aws_ram_resource_association`) so those get created against the shared account,
while everything else (VPC, TGW attachment) uses the default provider, which
assumes `terraform_role` in the spoke account itself.

## Prerequisites

- Terraform >= 0.12 (provider constraints require `hashicorp/aws >= 5.38.0`)
- AWS credentials with access to both the shared account and each spoke account
- An S3 bucket (and DynamoDB table or S3 lockfile support) for remote state

## Usage

1. **Create/update the S3 state bucket name** in each `providers.tf` `backend "s3"`
   block — bucket/key are hardcoded (Terraform backend blocks can't reference
   variables).

2. **Deploy the shared/hub environment first** — the spoke environment reads the
   TGW's ARN/ID from the shared environment's remote state:

   ```bash
   cd env/shared
   terraform init
   terraform apply \
     -var="project=myproject" \
     -var="vpc_cidr=10.150.0.0/16"
   ```

   Edit `ram_principals` in `tgw.tf` to list the real AWS account IDs of every
   spoke account that should be able to attach to this TGW (placeholders are
   redacted with `*` by default).

3. **Deploy each spoke environment**, pointing `main_tf_backend` at the shared
   environment's state so it can read `transit_gateway_arn` / `transit_gateway_id`:

   ```bash
   cd env/dev
   terraform init
   terraform apply \
     -var="project=myproject" \
     -var="account_id=<spoke-account-id>" \
     -var="vpc_cidr=10.151.0.0/16"
   ```

   `account_id` must match one of the account IDs listed in the shared
   environment's `ram_principals` — it's used both as the RAM principal and in
   the `assume_role` ARN for the spoke account's own provider.

## Key variables

| Variable | Where | Purpose |
|---|---|---|
| `project` / `environment` | both | Used to name the VPC/TGW: `${project}-${environment}-...` |
| `vpc_cidr`, `vpc_az`, `vpc_public_subnets`, `vpc_private_subnets` | both | VPC sizing |
| `main_tf_backend` | both | S3 backend to read remote state from (dev points at shared's state) |
| `tgw_name`, `tgw_amazon_side_asn` | shared | Transit Gateway settings |
| `account_id` | dev | Spoke account ID; used for RAM principal + assume-role ARN |

Full list with defaults and descriptions is in each environment's `vars.tf`.

## Notes / known gaps

- `env/shared/locals.tf` declares a `data.terraform_remote_state.shared_terraform`
  data source that nothing currently references — leftover from copying the spoke
  pattern into the hub. Safe to ignore or remove.
- The commented-out route table blocks in `env/dev/tgw_connections.tf` are left
  as a starting point if you need explicit routes to the TGW instead of relying
  on the VPC module's default routing.
