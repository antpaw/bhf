# bhf

## [Guide and Documentation](https://antpaw.github.io/bhf/)

## Contributing to bhf

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.


## Roadmap

* Adding unit tests and integration tests
* Adding bulk edit for the table view (aka platform)
* Manage relations with help of autocomplete inputs
* Move from MooTools to jQuery

## Support

<p><a href='https://pledgie.com/campaigns/25956'><img alt='Click here to lend your support to: bhf and make a donation at pledgie.com !' src='https://pledgie.com/campaigns/25956.png?skin_name=chrome' border='0' ></a></p>


## Copyright

Copyright (c) 2014 Anton Pawlik. See LICENSE.txt for
further details.


### Build

    gem install juwelier
    rake gemspec:generate
    git commit -m 'Regenerate gemspec for version 1.0.0.beta11' -a
    gem build bhf.gemspec
    gem push bhf-1.0.0.beta11.gem
