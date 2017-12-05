# dq-tf-business-data-manager

This Terraform module has one private subnet and deploys an EC2 instance representing a web server and an RDS instance. Allowing inbound HTTPS TCP traffic on port 443, inbound SSH TCP traffic on port 3389 and custom TCP traffic on 5432. 


## Connectivity

| In/Out        | Type           | Protocol | FromPort| To Port | TLS |
| ------------- |:-------------:| -----:| -----:|-----:| -----:|
|INBOUND | SSH | TCP |22 | 22| TLS to BDM ELB |
|INBOUND | HTTPS | TCP | 443 | 443 | TLS to BDM ELB |
|INBOUND | Custom TCP | TCP | 5432 | 5432 | TLS to BDM Postgres ELB |



## Usage

To run tests using the [tf testsuite](https://github.com/UKHomeOffice/dq-tf-testsuite):
```shell
drone exec --repo.trusted
```
To launch:
```shell
terraform apply
```

