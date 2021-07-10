require 'spec_helper'

describe WithGitRepo::VERSION do
  it 'has a version number' do
    refute_nil ::WithGitRepo::VERSION
  end
end
