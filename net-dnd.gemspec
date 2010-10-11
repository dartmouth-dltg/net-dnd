# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{net-dnd}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian V. Hughes"]
  s.date = %q{2010-10-11}
  s.default_executable = %q{net-dnd}
  s.description = %q{Ruby library for DND lookups.}
  s.email = %q{brianvh@dartmouth.edu}
  s.executables = ["net-dnd"]
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = [
    ".gitignore",
     "History.txt",
     "Manifest.txt",
     "README.txt",
     "Rakefile",
     "bin/net-dnd",
     "lib/net/dnd.rb",
     "lib/net/dnd/connection.rb",
     "lib/net/dnd/errors.rb",
     "lib/net/dnd/expires.rb",
     "lib/net/dnd/field.rb",
     "lib/net/dnd/profile.rb",
     "lib/net/dnd/response.rb",
     "lib/net/dnd/session.rb",
     "lib/net/dnd/user_spec.rb",
     "lib/net/dnd/version.rb",
     "net-dnd.gemspec",
     "spec/dnd/connection_spec.rb",
     "spec/dnd/field_spec.rb",
     "spec/dnd/profile_spec.rb",
     "spec/dnd/response_spec.rb",
     "spec/dnd/session_spec.rb",
     "spec/dnd/user_spec_spec.rb",
     "spec/spec_helper.rb",
     "stories/all.rb",
     "stories/helper.rb",
     "stories/multiple_find.rb",
     "stories/single_find.rb",
     "stories/steps/multiple_find_steps.rb",
     "stories/steps/single_find_steps.rb",
     "stories/stories/multiple_find.story",
     "stories/stories/single_find.story",
     "tasks/ann.rake",
     "tasks/bones.rake",
     "tasks/gem.rake",
     "tasks/git.rake",
     "tasks/manifest.rake",
     "tasks/notes.rake",
     "tasks/post_load.rake",
     "tasks/rdoc.rake",
     "tasks/rubyforge.rake",
     "tasks/setup.rb",
     "tasks/spec.rake",
     "tasks/svn.rake",
     "tasks/test.rake"
  ]
  s.homepage = %q{http://github.com/brianvh/net-dnd}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby library for DND lookups.}
  s.test_files = [
    "spec/dnd/connection_spec.rb",
     "spec/dnd/field_spec.rb",
     "spec/dnd/profile_spec.rb",
     "spec/dnd/response_spec.rb",
     "spec/dnd/session_spec.rb",
     "spec/dnd/user_spec_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end
