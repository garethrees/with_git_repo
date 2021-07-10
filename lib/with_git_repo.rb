require 'with_git_repo/version'
require 'git'

class WithGitRepo
  attr_reader :clone_url
  attr_reader :user_name
  attr_reader :user_email

  def initialize(options = {})
    @clone_url = options.fetch(:clone_url)
    @user_name = options.fetch(:user_name, 'with_git_repo')
    @user_email = options.fetch(:user_email, 'with_git_repo@everypolitician.org')
  end

  def commit_changes_to_branch(branch, message)
    checkout(branch)
    git.chdir { yield }
    git.add
    return unless git.status.changed.any? || git.status.added.any?
    git.commit(message)
    git.push('origin', branch)
  end

  private

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

  def git
    @git ||= Git.clone(clone_url, '.', path: Dir.mktmpdir).tap do |g|
      g.config('user.name', user_name)
      g.config('user.email', user_email)
    end
  end
end
