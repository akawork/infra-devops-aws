data "template_file" "sonar_properties" {
  template = file("../scripts/install_sonar.sh.tpl")

  vars = {
    db_endpoint = aws_db_instance.sonarqube.endpoint
    db_name     = var.sonar_db_name
    db_password = var.sonar_password
    db_username = var.sonar_username
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
  source_dir = "../configs/nginx/conf.d/"
  destination_dir = "../configs/nginx/conf.render/"

  vars = {
    jenkins_domain_name = aws_route53_record.jenkins.name
    sonar_domain_name = aws_route53_record.sonar.name
    nexus_domain_name = aws_route53_record.nexus.name
    gitlab_domain_name = aws_route53_record.gitlab.name
  }
}
