$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..')

require 'rubygems'
require 'highline/question'
require 'highline/import'
require 'highline/compatibility'
require 'octokit'
require 'teachers_pet/actions/base'

# This script should be run within a working directory that is a git repository.
# It will add a remote that is the name of each student team to your repository

module TeachersPet
  module Actions
    class PushFiles < Base
      def read_args(args)
        @repository = args[:repo]
        @organization = args[:org]
        @student_file = args[:students]
        @sshEndpoint = args[:ssh]
      end

      def load_files
        @students = read_file(@student_file, 'Students')
      end

      def push(args)
        confirm("Push files to student repositories?")
        self.init_client(args)

        org_hash = read_organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:url]}"

        # Load the teams - there should be one team per student.
        # Repositories are given permissions by teams
        org_teams = get_teams_by_name(@organization)

        # For each student - if an appropraite repository exists,
        # add it to the list.
        remotes_to_add = Hash.new
        @students.keys.sort.each do |student|
          unless org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end
          repo_name = "#{student}-#{@repository}"

          unless repository?(@organization, repo_name)
            puts("  ** ERROR ** - no repository called #{repo_name}")
          end
          if TeachersPet::Configuration.remoteSsh
            remotes_to_add[student] = "git@#{@sshEndpoint}:#{@organization}/#{repo_name}.git"
          else
            remotes_to_add[student] = "#{@web_endpoint}#{@organization}/#{repo_name}.git"
          end
        end

        puts "Adding remotes and pushing files to student repositories."
        remotes_to_add.keys.each do |remote|
          puts "#{remote} --> #{remotes_to_add[remote]}"
          `git remote add #{remote} #{remotes_to_add[remote]}`
          `git push #{remote} master`
        end
      end

      def run(args)
        self.read_args(args)
        self.load_files
        self.push(args)
      end
    end
  end
end
