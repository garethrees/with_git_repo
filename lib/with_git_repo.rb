require 'with_git_repo/version'
require 'git'

class WithGitRepo
  DEFAULT_USER_NAME = 'with_git_repo'.freeze
  DEFAULT_USER_EMAIL = 'with_git_repo@everypolitician.org'.freeze

  def self.with_cloned_repo(clone_url, options = {})
    path = options.fetch(:path, Dir.mktmpdir)
    new(git: configure_git!(Git.clone(clone_url, '.', path: path), options))
  end

  def self.configure_git!(git, options = {})
    git.config('user.name', options.fetch(:user_name, DEFAULT_USER_NAME))
    git.config('user.email', options.fetch(:user_email, DEFAULT_USER_EMAIL))
    git
  end

  attr_reader :clone_url
  attr_reader :user_name
  attr_reader :user_email

  def initialize(options = {})
    @clone_url = options.fetch(:clone_url, nil)
    @user_name = options.fetch(:user_name, DEFAULT_USER_NAME)
    @user_email = options.fetch(:user_email, DEFAULT_USER_EMAIL)
    @git = options.fetch(:git, nil)
  end

  def commit_changes_to_branch(branch, message)
    checkout(branch)
    git.chdir { yield }
    git.add
    git.commit(message) && git.push('origin', branch) if committable?
  end

  protected

  def git
    @git ||= default_git
  end

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

  def default_git
    Git.clone(clone_url!, '.', path: Dir.mktmpdir).tap do |g|
      g.config('user.name', user_name)
      g.config('user.email', user_email)
    end
  end

  def clone_url!
    msg = 'Must provide a clone_url option if no git option is given'
    raise ArgumentError, msg unless clone_url
    clone_url
  end
end
