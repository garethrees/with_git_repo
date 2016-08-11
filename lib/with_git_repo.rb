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
    checkout_branch!(branch)
    git.chdir { yield }
    git.add
    return unless git.status.changed.any? || git.status.added.any?
    git.commit(message)
    git.push('origin', branch)
  end

  private

  def checkout_branch!(branch)
    if git.branches[branch] || git.branches["origin/#{branch}"]
      git.checkout(branch)
    else
      git.checkout(branch, new_branch: true)
    end
  end

  def git
    @git ||= Git.clone(clone_url, '.', path: tmpdir).tap do |g|
      g.config('user.name', user_name)
      g.config('user.email', user_email)
    end
  end

  def tmpdir
    @tmpdir ||= Dir.mktmpdir
  end
end
