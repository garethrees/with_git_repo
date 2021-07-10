$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'with_git_repo'

require 'minitest/autorun'
require 'minitest/around/spec'
require 'fileutils'
require 'pry'

def with_tmpdir
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      copy_test_repo!
      yield dir
    end
  end
end

def test_repo_path
  File.expand_path('../support/with_git_repo.git', __FILE__)
end

def copy_test_repo!
  FileUtils.cp_r(test_repo_path, '.')
end

module MiniTest
  # Monkeypatch to add `context` helper
  class Spec
    class << self
      alias context describe
    end
  end
end
