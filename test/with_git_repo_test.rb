require 'test_helper'

class WithGitRepoTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::WithGitRepo::VERSION
  end
end
