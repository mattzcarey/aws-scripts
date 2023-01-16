# Useful scripts for deploying and tearing down AWS infrastructure

### Before running any of these scripts:

- Make sure aws cli by running `aws --version`
- Make scripts executable by running `chmod +x ./scripts/*.sh`
- Setup aws credentials by running `aws configure` or using [Leapp](https://www.leapp.cloud/)
- In redeploy.sh, change the STAGE and REGION to the desired values. Update account names to match your aws account names/profiles or uncomment default.

### To run redeploy script:

- Run `./scripts/redeploy-stack.sh`
