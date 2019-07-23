# Infrastructure as Code for DevOps System on AWS

This project buiding on frameworks:
1. Terraform
2. Ansible

## Contents
  1.  [Precondition](#Precondition)

      1.1. [Setup AWS authentication](#Setup-AWS-authentication)

  2.  [Architecture](#Architecture)

      2.1. [Architecture for Hybrid DevOps System](#Architecture-for-Hybrid-DevOps-System)

## Checklist

  - [x] Create network base on Architecture
    - [x] VPC: 10.15.0.0/16
    - [x] Subnet: 7 subnets (1 public subnet, 2 application subnets, 2 agent subnets, 2 private subnets)
    - [x] Router table: Internet > DevOps via Internet gateway, DevOps > Internet via NAT Gateway
    - [x] Gateway: Internet Gateway and NAT Gateway
    - [x] Security Group: Update inbound and outbound for all server
    - [x] EIP: only NAT gateway and NginX server have EIP
  - [ ] Create Instances will using as Architecture
  - [ ] Create script for auto install applications
    - [ ] Bastion
    - [ ] NginX
    - [ ] Squid
    - [ ] Jira
    - [ ] Confluence
    - [ ] Sonarqube
    - [ ] GitLab
    - [ ] Jenkins
    - [ ] Nexus Repository
    - [ ] OpenLdap
  - [ ] Lambda function for auto turn-on and turn-off AWS Instances

## Precondition

### Setup AWS authentication

Create or edit file `~/.aws/credentials` file and add below content to that file:

```
[default]
aws_access_key_id = aaaaaa
aws_secret_access_key = bbbbbbb
```

with 
 - `default` is default profile. Terraform default using this profile for creating infrastructure on AWS
 - `aaaaaa` is access key
 - `bbbbbbb` is secret access key

## Architecture

### Architecture for Hybrid DevOps System

![DevOps_AWS_Detail_Architecture](./docs/images/DevOps_AWS_Hybrid-Detail.jpg)

