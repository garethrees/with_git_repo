$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'with_git_repo'

require 'minitest/autorun'

module MiniTest
  # Monkeypatch to add `context` helper
  class Spec
    class << self
      alias context describe
    end
  end
end
