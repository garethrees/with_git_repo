require 'spec_helper'
describe WithGitRepo do
  describe '.with_cloned_repo' do
    subject { WithGitRepo.with_cloned_repo(clone_url, options) }

    let(:clone_url) { "file://#{@dir}/with_git_repo.git" }
    let(:default_options) { {} }

    around do |test|
      with_tmpdir do |dir|
        @dir = dir
        test.call
      end
    end

    context 'with the default options' do
      let(:options) { default_options }

      it 'initialises with the cloned repo' do
        assert_equal clone_url, subject.send(:git).remotes.first.url
      end

      it 'clones the repo into a tmpdir' do
        assert_match Regexp.new(Dir.tmpdir), subject.send(:git).dir.path
      end

      it 'sets the user.name to the default user name' do
        name = WithGitRepo::DEFAULT_USER_NAME
        assert_equal name, subject.send(:git).config['user.name']
      end

      it 'sets the user.email to the default user email' do
        email = WithGitRepo::DEFAULT_USER_EMAIL
        assert_equal email, subject.send(:git).config['user.email']
      end
    end

    context 'with the user_name option' do
      let(:options) { default_options.merge(user_name: 'foo') }

      it 'sets the user.name to the given user name' do
        assert_equal 'foo', subject.send(:git).config['user.name']
      end
    end

    context 'with the user_email option' do
      let(:options) { default_options.merge(user_email: 'foo@example.com') }

      it 'sets the user.name to the given user name' do
        assert_equal 'foo@example.com', subject.send(:git).config['user.email']
      end
    end

    context 'with the path option' do
      let(:options) { default_options.merge(path: Dir.mktmpdir('foo')) }

      it 'clones the repo into the given path' do
        regexp = Regexp.new("#{Dir.tmpdir}/foo")
        assert_match regexp, subject.send(:git).dir.path
      end
    end
  end

  describe '.with_working_copy' do
    subject { WithGitRepo.with_working_copy(path, options) }

    let(:path) { nil }
    let(:working_copy_path) { Dir.mktmpdir('working-copy-') }
    let(:default_options) { {} }

    around do |test|
      Dir.chdir(working_copy_path) do
        Git.clone(test_repo_path, '.', path: working_copy_path)
        test.call
      end
    end

    context 'with the default options' do
      let(:options) { default_options }

      it 'initialises with the working copy in the current directory' do
        regexp = Regexp.new(working_copy_path)

        Dir.chdir(working_copy_path) do
          assert_match regexp, subject.send(:git).dir.path
        end
      end

      it 'sets the user.name to the default user name' do
        name = WithGitRepo::DEFAULT_USER_NAME
        assert_equal name, subject.send(:git).config['user.name']
      end

      it 'sets the user.email to the default user email' do
        email = WithGitRepo::DEFAULT_USER_EMAIL
        assert_equal email, subject.send(:git).config['user.email']
      end
    end

    context 'with the user_name option' do
      let(:options) { default_options.merge(user_name: 'foo') }

      it 'sets the user.name to the given user name' do
        assert_equal 'foo', subject.send(:git).config['user.name']
      end
    end

    context 'with the user_email option' do
      let(:options) { default_options.merge(user_email: 'foo@example.com') }

      it 'sets the user.name to the given user name' do
        assert_equal 'foo@example.com', subject.send(:git).config['user.email']
      end
    end

    context 'when given a path' do
      let(:path) { working_copy_path }
      let(:options) { default_options }

      it 'initialises with the working copy in the given directory' do
        regexp = Regexp.new(working_copy_path)
        assert_match regexp, subject.send(:git).dir.path
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
    let(:default_options) { { } }
    let(:options) { default_options }

    let(:with_git_repo) do
      WithGitRepo.with_cloned_repo(clone_url, options)
    end

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

  describe '#commit_changes' do
    subject do
      with_git_repo.commit_changes(msg) do
        block.call
      end
    end

    let(:with_git_repo) { WithGitRepo.with_working_copy(working_copy_path) }
    let(:msg) { 'a commit message' }

    let(:working_copy_path) { Dir.mktmpdir('working-copy-') }

    around do |test|
      Dir.chdir(working_copy_path) do
        Git.clone(test_repo_path, '.', path: working_copy_path)
        test.call
      end
    end

    before { subject }

    let(:git) { Git.open(working_copy_path) }

    context 'when there are changes' do
      let(:block) { -> { File.write('greeting.txt', 'Hello, world!') } }

      it 'the changed file has the correct contents' do
        blob = git.gcommit('HEAD').gtree.blobs['greeting.txt']
        assert_equal 'Hello, world!', blob.contents
      end

      it 'commits the changes with the given message' do
        assert_equal 'a commit message', git.gcommit('HEAD').message
      end
    end

    context 'when nothing changes' do
      let(:block) { -> { nil } }

      it 'nothing is committed' do
        refute_equal 'a commit message', git.gcommit('HEAD').message
      end
    end
  end
end
