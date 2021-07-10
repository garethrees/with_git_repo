# WithGitRepo

Perform some actions with a git repo and then commit and push the changes back.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'with_git_repo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install with_git_repo

## Usage

```ruby
require 'with_git_repo'

with_git_repo = WithGitRepo.new(
  clone_url: 'https://username:access_token@github.com/everypolitician/with_git_repo',
  user_name: 'Chris Mytton',
  user_email: 'team@everypolitician.org'
)
with_git_repo.commit_changes_to_branch('example-branch-name', 'Adding greeting.txt') do
  File.write('greeting.txt', 'Hello, world!')
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/everypolitician/with_git_repo.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
