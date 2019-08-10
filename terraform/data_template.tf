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

resource "template_dir" "nginx_conf" {
  source_dir      = "../configs/nginx/conf.d/"
  destination_dir = "../configs/nginx/conf.render/"

  vars = {
    jenkins_domain_name = aws_route53_record.jenkins.name
    sonar_domain_name   = aws_route53_record.sonar.name
    nexus_domain_name   = aws_route53_record.nexus.name
    gitlab_domain_name  = aws_route53_record.gitlab.name
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
