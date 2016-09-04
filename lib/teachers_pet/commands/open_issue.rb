module TeachersPet
  class Cli
    option :organization, required: true
    option :repository, required: true

    option :title, desc: "The title of the issue to be created"
    option :body, banner: 'PATH', desc: "The path to the file containing the issue body (.txt or .md)"
    option :labels, banner: 'LABEL1,LABEL2'
    option :path, desc: 'Relative path to the folder containing the issue body (student.md)'

    students_option
    common_options

    desc "open_issue", "Opens a single issue in each repository in the organization."
    def open_issue
      TeachersPet::Actions::OpenIssue.new(options).run
    end
  end
end
