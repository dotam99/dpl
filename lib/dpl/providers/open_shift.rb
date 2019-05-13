module Dpl
  module Providers
    class OpenShift < Provider
      requires 'rhc'

      summary 'Openshift deployment provider'

      description <<~str
        tbd
      str

      opt '--user NAME',     'OpenShift username', required: true
      opt '--password PASS', 'OpenShift password', required: true
      opt '--domain DOMAIN', 'OpenShift application domain', required: true
      opt '--app APP',       'OpenShift application', default: :repo_name
      # not mentioned in the readme or docs
      opt '--deployment_branch BRANCH'

      needs :git, :ssh_key

      SERVER = 'openshift.redhat.com'

      msgs login:           'Authenticated as %{user}',
           validate:        'Found application %s',
           deploy_branch:   'Deployment branch: %{deployment_branch}'

      cmds git_push:        'git push %{git_url} -f',
           git_push_branch: 'git push %{git_url} -f %{deployment_branch}'

      def api
        @api ||= ::RHC::Rest::Client.new(user: user, password: password, server: SERVER)
      end

      def login
        api.user.login
        info :login
      end

      def validate
        info :validate, application.name
      end

      def add_key(file)
        type, content, _ = File.read(file).split
        api.add_key(key_name, content, type)
      end

      def deploy
        if deployment_branch?
          info :deploy_branch
          application.deployment_branch = deployment_branch # does this have any effect?
          shell :git_push_branch
        else
          shell :git_push
        end
      end

      def remove_key
        api.delete_key(key_name)
      end

      def restart
        application.restart
      end

      def git_url
        application.git_url
      end

      def application
        @application ||= api.find_application(domain, app)
      end
    end
  end
end