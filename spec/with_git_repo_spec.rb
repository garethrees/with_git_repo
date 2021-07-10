require 'spec_helper'

describe WithGitRepo do
  describe '#user_name' do
    subject { with_git_repo.user_name }

    let(:with_git_repo) { WithGitRepo.new(options) }

    let(:default_options) { { clone_url: nil } }

    context 'with no user_name option supplied' do
      let(:options) { default_options }

      it 'uses the default user_name' do
        assert_equal 'with_git_repo', subject
      end
    end

    context 'with a user_name option supplied' do
      let(:options) { default_options.merge(user_name: 'foo') }

      it 'uses the given user_name' do
        assert_equal 'foo', subject
      end
    end
  end

  describe '#user_email' do
    subject { with_git_repo.user_email }

    let(:with_git_repo) { WithGitRepo.new(options) }

    let(:default_options) { { clone_url: nil } }

    context 'with no user_email option supplied' do
      let(:options) { default_options }

      it 'uses the default user_email' do
        assert_equal 'with_git_repo@everypolitician.org', subject
      end
    end

    context 'with a user_email option supplied' do
      let(:options) { default_options.merge(user_email: 'foo@example.com') }

      it 'uses the given user_email' do
        assert_equal 'foo@example.com', subject
      end
    end
  end

  describe '#commit_changes_to_branch' do
    subject do
      with_git_repo.commit_changes_to_branch(branch, msg) do
        File.write('greeting.txt', 'Hello, world!')
      end
    end

    let(:clone_url) { "file://#{@dir}/with_git_repo.git" }
    let(:default_options) { { clone_url: clone_url } }
    let(:options) { default_options }
    let(:with_git_repo) { WithGitRepo.new(options) }

    let(:branch) { 'master' }
    let(:msg) { 'a commit message' }

    around do |test|
      with_tmpdir do |dir|
        @dir = dir
        test.call
      end
    end

    before { subject }

    let(:git) do
      Git.clone(clone_url, 'cloned_repo_after_subject', path: Dir.mktmpdir)
    end

    it 'the changed file has the correct contents' do
      blob = git.gcommit('HEAD').gtree.blobs['greeting.txt']
      assert_equal 'Hello, world!', blob.contents
    end

    it 'commits the changes with the given message' do
      assert_equal 'a commit message', git.gcommit('HEAD').message
    end

    context 'when using the default branch' do
      it 'pushes the changed file after committing' do
        refute_nil git.gcommit('HEAD').gtree.blobs['greeting.txt']
      end
    end

    context 'when using a non-default branch that does not exist' do
      let(:branch) { 'new-branch' }

      it 'pushes the changed file to the given branch after committing' do
        commit = git.branches['origin/new-branch'].gcommit
        refute_nil commit.gtree.blobs['greeting.txt']
      end
    end

    context 'when using a non-default branch that already exists' do
      let(:branch) { 'existing-branch' }

      before do
        with_git_repo.commit_changes_to_branch(branch, 'msg') do
          File.write('before.txt', 'before assert')
        end
      end

      it 'pushes the changed file to the given branch after committing' do
        commit = git.branches['origin/existing-branch'].gcommit
        refute_nil commit.gtree.blobs['greeting.txt']
      end
    end

    context 'with the default user.name' do
      it 'commits the changes with the default user.name' do
        assert_equal 'with_git_repo', git.gcommit('HEAD').author.name
      end
    end

    context 'with an optional user.name' do
      let(:options) { default_options.merge(user_name: 'foo') }

      it 'commits the changes with the optional user.name' do
        assert_equal 'foo', git.gcommit('HEAD').author.name
      end
    end

    context 'with the default user.email' do
      it 'commits the changes with the default user.email' do
        default_email = 'with_git_repo@everypolitician.org'
        assert_equal default_email, git.gcommit('HEAD').author.email
      end
    end

    context 'with an optional user.email' do
      let(:options) { default_options.merge(user_email: 'foo@example.com') }

      it 'commits the changes with the optional user.email' do
        assert_equal 'foo@example.com', git.gcommit('HEAD').author.email
      end
    end
  end
end
