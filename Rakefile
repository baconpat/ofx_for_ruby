# Copyright © 2007 Chris Guidry <chrisguidry@gmail.com>
#
# This file is part of OFX for Ruby.
# 
# OFX for Ruby is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# OFX for Ruby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'bundler/setup'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'


Rake::TestTask.new do |t|
    t.test_files = FileList['test/**/test_*.rb']
    t.verbose = true
end

Rake::RDocTask.new do |rd|
    rd.title = "OFX - an OFX implementation for Ruby"
    rd.rdoc_files.include("lib/**/*.rb")
    rd.rdoc_files.exclude("lib/**/parser.rb")
    rd.rdoc_files.exclude("lib/**/lexer.rb")
    rd.rdoc_dir = "documentation/api"
end

# RCOV command, run as though from the commandline.  Amend as required or perhaps move to config/environment.rb?
RCOV = "bundle exec rcov -Ilib --xref --profile"

desc "generate a unit coverage report in coverage"
task :"coverage" do
    sh "#{RCOV} --output coverage test/test_*.rb test/**/test_*.rb"
end

desc "runs coverage and rdoc"
task :default => [:coverage, :rdoc]


desc "recreates parsers"
task :parsers do
    sh "cd lib/ofx/1.0.2; bundle exec rex -o lexer.rb ofx_102.rex"
    sh "cd lib/ofx/1.0.2; bundle exec racc -o parser.rb ofx_102.racc"
end

task :test => :parsers
task :coverage => :parsers
task :rdoc => :parsers
task :build => :parsers
task :release => :parsers
task :install => :parsers