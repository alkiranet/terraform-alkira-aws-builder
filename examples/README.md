## Example Project
The following example project provisions resources defined in **aws_vpcs.yaml** in various combinations.

### Usage
To use this example, fill in the appropriate values in _variables.tf_ and provide those values _(including any secrets)_ by way of _terraform.tfvars_ or desired secrets management platform. Then run:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

### **Scenario A:** Connect existing _AWS VPCs_
The following portion of the example configuration will create an [alkira_connector_aws_vpc](https://registry.terraform.io/providers/alkiranet/alkira/latest/docs/resources/connector_aws_vpc) resource from configuration defined in **aws_vpcs.yaml** using the AWS _network_cidr_ and _network_id_.

```yaml
---
aws_vpc:

  # Connect VPC that already exists to Alkira
  - name: 'vpc-east-dev'
    aws_account_id: '12345678'
    region: 'us-east-2'
    credential: 'aws'
    cxp: 'us-east-2'
    group: 'nonprod'
    segment: 'business'
    network_cidr: '10.5.0.0/16'
    network_id: 'vpc-012345678' # replace with appropriate id
...
```

### **Scenario B:** Provision new _AWS VPCs_ and connect to _Alkira_
The following portion of the example configuration will create an [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) and [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) resources and then connect _VPC_ to _Alkira_ with an [alkira_connector_aws_vpc](https://registry.terraform.io/providers/alkiranet/alkira/latest/docs/resources/connector_aws_vpc) resource.

:vertical_traffic_light: The optional parameter **_create_vm: true_** can be added to provision a _lightweight_ EC2 instance running [Ubuntu 20.04 LTS](https://releases.ubuntu.com/focal/) with _t2.nano_ as the default instance type. You can add an additional parameter under _subnets_ to specify an alternative type - **_vm_type: t2.large_**. Additionally, _availability-zones_ can optionally be specified for each subnet using - **_zone: us-east-2a_**.

```yaml
---
aws_vpc:

  # Provision new VPC and connect to Alkira
  - name: 'vpc-east-qa'
    billing_tag: 'app-team-a'
    create_network: true # This parameter should be set to 'true'
    aws_account_id: '12345678'
    region: 'us-east-2'
    credential: 'aws'
    cxp: 'us-east-2'
    group: 'nonprod'
    segment: 'business'
    network_cidr: '10.6.0.0/16'
    subnets:
      - name: 'subnet1-qa'
        cidr: '10.6.1.0/24'
        create_vm: true # Optional attribute to provision instances on a per subnet basis

      - name: 'subnet2-qa'
        cidr: '10.6.2.0/24'
        create_vm: true
        zone: 'us-east-2a' # Optionally specify availability-zone
        vm_type: 't2.large' # Optionally specify instance type
...
```

### **Scenario C:** Provision new _AWS VPCs_ only
The following portion of the example configuration will create an [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) and [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) resources without connecting them to _Alkira_. For this scenario, simply add the parameter **_connect_network: false_**.

```yaml
---
aws_vpc:

  - name: 'vpc-east-sbox'
    create_network: true # This parameter should be set to 'true'
    connect_network: false # This parameter should be set to 'false'
    aws_account_id: '12345678'
    region: 'us-east-2'
    network_cidr: '10.7.0.0/16'
    subnets:
      - name: 'subnet1-sbox'
        cidr: '10.7.1.0/24'
        create_vm: true # Optional attribute to provision instances on a per subnet basis

      - name: 'subnet2-sbox'
        cidr: '10.7.2.0/24'
    tags: # Optional AWS tags to add to resources
      email: 'me@email.com'
      env: 'sbox'
...
```