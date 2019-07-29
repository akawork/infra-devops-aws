data "template_file" "sonar_properties" {
  template = file("../scripts/install_sonar.sh.tpl")

  vars = {
    db_endpoint = aws_db_instance.sonarqube.endpoint
    db_name     = var.sonar_db_name
    db_password = var.sonar_password
    db_username = var.sonar_username
    sonar_version = "sonarqube-7.9"
  }
}

data "template_file" "nexus_properties" {
  template = file("../scripts/install_nexus.sh.tpl")

  vars = {
    nexus_version = "nexus-3.17.0-01"
  }
}

