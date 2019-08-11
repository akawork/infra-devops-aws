data "template_file" "sonar_properties" {
  template = file("../scripts/install_sonar.sh.tpl")

  vars = {
    db_endpoint   = aws_db_instance.sonarqube.endpoint
    db_name       = var.sonar_db_name
    db_password   = var.sonar_password
    db_username   = var.sonar_username
    sonar_version = var.sonar_version
  }
}

data "template_file" "nexus_properties" {
  template = file("../scripts/install_nexus.sh.tpl")

  vars = {
    nexus_version = var.nexus_version
  }
}

data "template_file" "jira_properties" {
  template = file("../scripts/install_jira.sh.tpl")

  vars = {
    jira_version  = var.jira_version
  }
}

resource "template_dir" "jira_config" {
  source_dir      = "../configs/jira/"
  destination_dir = "../configs/jira/conf.render/"

  vars = {
    db_endpoint   = aws_db_instance.jira.endpoint
    db_name       = var.jira_db_name
    db_password   = var.jira_password
    db_username   = var.jira_username
  }
}

resource "template_dir" "nginx_conf" {
  source_dir      = "../configs/nginx/conf.d/"
  destination_dir = "../configs/nginx/conf.render/"

  vars = {
    jenkins_domain_name = aws_route53_record.jenkins.name
    sonar_domain_name   = aws_route53_record.sonar.name
    nexus_domain_name   = aws_route53_record.nexus.name
    gitlab_domain_name  = aws_route53_record.gitlab.name
    jira_domain_name    = aws_route53_record.jira.name
  }
}

data "template_file" "gitlab_install" {
  template = file("../scripts/install_gitlab.sh.tpl")

  vars = {
    db_endpoint = aws_db_instance.gitlab.endpoint
    db_name     = var.gitlab_db_name
    db_password = var.gitlab_password
    db_username = var.gitlab_username
    git_domain  = aws_route53_record.gitlab.name
  }
}

resource "template_dir" "gitlab_config" {
  source_dir      = "../configs/gitlab/"
  destination_dir = "../configs/gitlab/conf.render/"

  vars = {
    db_endpoint = aws_db_instance.gitlab.address
    db_name     = var.gitlab_db_name
    db_password = var.gitlab_password
    db_username = var.gitlab_username
    git_domain  = aws_route53_record.gitlab.name
    git_url     = "http://${aws_route53_record.gitlab.name}"
  }
}

data "template_file" "bastion_config" {
  template = file("../scripts/config_bastion.sh.tpl")

  vars = {
    squid_password   = var.squid_password
    squid_username   = var.squid_username
    squid_ip         = var.squid_ip
    squid_port       = var.squid_port
    internal_ssh_key = aws_key_pair.internal.key_name
  }
}

data "template_file" "squid_install" {
  template = file("../scripts/install_squid.sh.tpl")

  vars = {
    squid_password = var.squid_password
    squid_username = var.squid_username
  }
}

resource "template_dir" "squid_config" {
  source_dir      = "../configs/squid/"
  destination_dir = "../configs/squid/conf.render/"

  vars = {
    public_ip_range       = aws_subnet.public-subnet.cidr_block
    application1_ip_range = aws_subnet.application1-subnet.cidr_block
    application2_ip_range = aws_subnet.application2-subnet.cidr_block
    agent1_ip_range       = aws_subnet.agent1-subnet.cidr_block
    agent2_ip_range       = aws_subnet.agent2-subnet.cidr_block
    squid_port            = var.squid_port
  }
}
