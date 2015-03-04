module Sinicum
  # Private: Generator to install all Sinicum-related files to a Rails
  # project.
  class InstallGenerator < Rails::Generators::Base
    GROUP_ID = "com.company"
    ARTIFACT_ID = "myProject"
    PROJECT_NAME = "My Sinicum Project"
    MODULE_NAME = "myproject"

    DB_HOST = "localhost"

    source_root File.expand_path("../templates", __FILE__)

    attr_accessor :group_id, :artifact_id, :project_name, :module_name,
      :db_host, :db_password

    def start_install
      user_questions
      create_basic_files
      create_mgnl_config
      create_rails_files
      update_gitignore
      create_template_files if @templates == "yes"
    end

    private

    def user_questions
      @group_id = ask("Please enter Maven's groupId [#{GROUP_ID}]:").presence ||
        GROUP_ID
      @artifact_id = ask("Please enter Maven's artifactId [#{ARTIFACT_ID}]:").presence ||
        ARTIFACT_ID
      @project_name = ask("Please enter the project name [#{PROJECT_NAME}]:").presence ||
        PROJECT_NAME
      @module_name = ask("Please enter the name of the module [#{MODULE_NAME}]:").presence ||
        MODULE_NAME
      @db_host = ask("Please enter the hostname of the Magnolia Postgres database server" +
        " [#{DB_HOST}]:").presence || DB_HOST
      @db_name = ask("Please enter the name of the Magnolia development database [#{db_name}]:")
      @db_user = ask("Please enter the database's user [#{db_user}]:")
      @db_password = ask("Please enter the database's password []:")
      @templates = ask("Would you like to install an example content template? [yes]").
        presence || "yes"
    end

    def create_basic_files
      template "project-pom.xml", "pom.xml"
      template "module-pom.xml", "#{module_path}/pom.xml"
      create_file "#{module_path}/src/test/java/.gitkeep"
      create_file "#{module_path}/src/main/resources/mgnl-bootstrap/#{module_name}/.gitkeep"
      template "module-config.xml",
        "#{module_path}/src/main/resources/META-INF/magnolia/#{module_name}.xml"
      template "VersionHandler.java", version_handler_path
    end

    def create_mgnl_config
      template "config/default/magnolia.properties",
        "#{config_dir}/default/magnolia.properties"
      template "config/default/magnolia-author.properties",
        "#{config_dir}/author/magnolia.properties"
      template "config/default/magnolia-public01.properties",
        "#{config_dir}/public01/magnolia.properties"

      template "config/default/log4j-development.xml",
        "#{config_dir}/default/log4j-development.xml"
      template "config/default/log4j.xml",
        "#{config_dir}/default/log4j.xml"

      template "config/repo-conf/jackrabbit-bundle-postgres-search.xml",
        "#{config_dir}/repo-conf/jackrabbit-bundle-postgres-search.xml"
      template "config/repo-conf/jackrabbit-bundle-postgres-search-author.xml",
        "#{config_dir}/repo-conf/jackrabbit-bundle-postgres-search-author.xml"
      template "config/repo-conf/jackrabbit-bundle-postgres-search-public01.xml",
        "#{config_dir}/repo-conf/jackrabbit-bundle-postgres-search-public01.xml"
    end

    def create_rails_files
      template "rails/content_controller.rb",
        "app/controllers/content_controller.rb"
      template "rails/sinicum_server.yml",
        "config/sinicum_server.yml"
      template "rails/imaging.yml",
        "config/imaging.yml"
      insert_into_file "config/routes.rb", before: /^end$/ do
        <<EOF

  scope ':site_prefix' do
    get '*cmspath' => 'content#index'
    root 'content#index'
  end

  get '*cmspath' => 'content#index'
EOF
      end
      insert_into_file "app/helpers/application_helper.rb", after: "ApplicationHelper" do
        <<EOF

  include Sinicum::MgnlHelper5
EOF
      end
    end

    def create_template_files
      template "rails/application.html.haml",
        "app/views/layouts/#{@module_name}/application.html.haml"
      template "rails/_meta.html.haml",
        "app/views/shared/_meta.html.haml"
      template "rails/_content.html.haml",
        "app/views/mgnl/areas/_content.html.haml"
      template "rails/_article.html.haml",
        "app/views/mgnl/#{@module_name}/components/_article.html.haml"
      template "magnolia/config.modules.myproject.dialogs.xml",
        "#{bootstrap_dir}/config.modules.#{@module_name}.dialogs.xml"
      template "magnolia/config.modules.myproject.templates.xml",
        "#{bootstrap_dir}/config.modules.#{@module_name}.templates.xml"
      remove_file "app/views/layouts/application.html.erb"
    end

    def update_gitignore
      inject_into_file '.gitignore', after: "/tmp" do
        <<EOF

#{module_path}/target/*
/db/magnolia/*
EOF
      end
    end

    def module_path
      "magnolia-#{module_name}"
    end

    def version_handler_fqn
      [version_handler_package, "VersionHandler"].join(".")
    end

    def version_handler_package
      [group_id, artifact_id].join(".")
    end

    def version_handler_path
      ["#{module_path}/src/main/java", version_handler_fqn.gsub(".", "/")].
        join("/") + ".java"
    end

    def config_dir
      "#{module_path}/src/main/webapp/WEB-INF/config"
    end

    def bootstrap_dir
      "#{module_path}/src/main/resources/mgnl-bootstrap/#{@module_name}"
    end

    def db_name
      @db_name.presence || "#{module_name}_author"
    end

    def db_user
      @db_user.presence || "#{module_name}author"
    end
  end
end
