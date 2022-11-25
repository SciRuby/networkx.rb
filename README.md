# NetworkX.rb

[![Gem Version](https://badge.fury.io/rb/networkx.svg)](https://badge.fury.io/rb/networkx)

[NetworkX](https://networkx.github.io/) is a very popular Python library, that handles various use-cases of the Graph Data Structure.  
This project intends to provide a working alternative to the Ruby community, by closely mimicing as many features as possible. 

## List of contents

- [Installing](#installing)
- [Document](#document)
- [Contributing](#contributing)
- [License](#license)

## Installing

- Clone the repository or fork
  - Clone this repository with `git clone https://github.com/SciRuby/networkx.rb.git`
  - or You can fork and do clone it.
- Navigate to networkx with `cd networkx.rb`
- Install dependencies with `gem install bundler && bundle install`

```ruby
require 'networkx'

g = NetworkX::Graph.new
g.add_edge('start', 'stop')
``` 

## Document

You can read [Document](https://SciRuby.github.io/networkx.rb/) for this library.

## Contributing

Your contributions are always welcome!  
Please have a look at the [contribution guidelines](CONTRIBUTING.md) first. :tada:

## License

The MIT License 2017 - [Athitya Kumar](https://github.com/athityakumar).   
Please have a look at the [LICENSE.md](LICENSE.md) for more details.
