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
end
