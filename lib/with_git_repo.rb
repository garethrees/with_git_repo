require 'with_git_repo/version'
require 'git'

class WithGitRepo
  DEFAULT_USER_NAME = 'with_git_repo'.freeze
  DEFAULT_USER_EMAIL = 'with_git_repo@everypolitician.org'.freeze

  def self.with_cloned_repo(clone_url, options = {})
    path = options.fetch(:path, Dir.mktmpdir)
    new(configure_git!(Git.clone(clone_url, '.', path: path), options))
  end

  def self.with_working_copy(path, options = {})
    path ||= Dir.pwd
    new(configure_git!(Git.open(path), options))
  end

  def self.configure_git!(git, options = {})
    git.config('user.name', options.fetch(:user_name, DEFAULT_USER_NAME))
    git.config('user.email', options.fetch(:user_email, DEFAULT_USER_EMAIL))
    git
  end

  def initialize(git)
    @git = git
  end

  def commit_changes_to_branch(branch, message)
    checkout(branch)
    git.chdir { yield }
    git.add
    git.commit(message) && git.push('origin', branch) if committable?
  end

  def commit_changes(message)
    git.chdir { yield }
    git.add
    git.commit(message) if committable?
  end

  protected

  attr_reader :git

  private

  def committable?
    git.status.changed.any? || git.status.added.any?
  end

  def checkout(branch)
    return unless branch
    checkout_existing(branch) || create_and_checkout(branch)
  end

  def checkout_existing(branch)
    exists?(branch) && git.checkout(branch)
  end

  def create_and_checkout(branch)
    git.checkout(branch, new_branch: true)
  end

  def exists?(branch)
    git.branches[branch] || git.branches["origin/#{branch}"]
  end
end
