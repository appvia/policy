# Appvia Policy as Code for Terraform and Kubernetes Resources

This repository contains Appvia company policies that have been codified into [kyverno](https://kyverno.io/) and [checkov](https://www.checkov.io/) policies.

## Usage

A working example will be made available in the [tf-aws-rds-postgres](https://github.com/appvia/tf-aws-rds-postgres) Terraform Module.

## Terraform IaC Policies

These policies exist within the [infra/](./infra) directory, with sub-directories created for grouped policies which may be applied independently depending on the particular use case. For now we have a [generic](./infra/generic) policy package defined which should be applied against all resources created within this Organisation.

### Official Policies

Checkov has a collection of built-in [Terraform resource scan checks](https://www.checkov.io/5.Policy%20Index/terraform.html), which can be referenced directly in our [policy config](./infra/generic/config.yaml) and used for resource scanning. To include an official policy in our policy package, the ID for that policy simply needs referencing within the [config yaml](./infra/generic/config.yaml).

### Custom Policies

Any custom policies to be defined which are not otherwise available as part of the built-in Checkov policies, can be created locally within this repository by following the below steps:
1. Create a directory within the relevant policy package for your new custom policy, e.g. ["./infra/generic/example-rds-encrypted-storage"](./infra/generic/example-rds-encrypted-storage)
2. Create a ["policy.yaml"](./infra/generic/example-rds-encrypted-storage/policy.yaml) defining the metadata (name, id, category) and the policy definition itself. [Checkov official documentation](https://www.checkov.io/3.Custom%20Policies/YAML%20Custom%20Policies.html) provides a breakdown of what is contained in this policy file.
3. Create test Terraform files in the same directory with the naming convention `pass[numeric-id].tf` and `fail[numeric-id].tf` which are used to validate against your policy.

You can manually test this policy by running the following:
```bash
# Run all custom tests
./infra/generate-bats-tests.sh
bats infra-tests.bats

# Run custom test files individually against your new policy
policy_testfile="pass0.tf"
policy_dir="infra/generic/example-rds-encrypted-storage"
policy_id=`yq eval '.metadata.id' ${policy_dir}/policy.yaml`
checkov --framework terraform -f ${policy_dir}/${policy_testfile} --external-checks-dir ${policy_dir} --check ${policy_id}
```

## More Info

See the [What is Policy As [versioned] Code? blog post](https://www.appvia.io/blog/policy-as-versioned-code) for more information.
