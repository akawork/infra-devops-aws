## GitLab configuration settings
##! This file is generated during initial installation and **is not** modified
##! during upgrades.
##! Check out the latest version of this file to know about the different
##! settings that can be configured by this file, which may be found at:
##! https://gitlab.com/gitlab-org/omnibus-gitlab/raw/master/files/gitlab-config-template/gitlab.rb.template


## GitLab URL
##! URL on which GitLab will be reachable.
##! For more details on configuring external_url see:
##! https://docs.gitlab.com/omnibus/settings/configuration.html#configuring-the-external-url-for-gitlab
external_url '${git_url}'

### GitLab database settings
###! Docs: https://docs.gitlab.com/omnibus/settings/database.html
###! **Only needed if you use an external database.**
postgresql['enable'] = false
gitlab_rails['db_adapter'] = "postgresql"
gitlab_rails['db_encoding'] = "utf8"
# gitlab_rails['db_collation'] = nil
gitlab_rails['db_database'] = '${db_name}'
# gitlab_rails['db_pool'] = 10
gitlab_rails['db_username'] = '${db_username}'
gitlab_rails['db_password'] = '${db_password}'
gitlab_rails['db_host'] = '${db_endpoint}'
gitlab_rails['db_port'] = 5432
# gitlab_rails['db_socket'] = nil
# gitlab_rails['db_sslmode'] = nil
# gitlab_rails['db_sslcompression'] = 0
# gitlab_rails['db_sslrootcert'] = nil
# gitlab_rails['db_prepared_statements'] = false
# gitlab_rails['db_statements_limit'] = 1000
