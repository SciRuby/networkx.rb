# NetworkX.rb

[NetworkX](https://networkx.github.io/) is a very popular Python library, that handles various use-cases of the Graph Data Structure. This project intends to provide a working alternative to the Ruby community, by closely mimicing as many features as possible. 

*This project has begun just now, and a v0.1.0 release with basic Graph classes can be expected by January 2018.*

### List of contents

- [Installing](#installing)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

### Installing

[(Back to top)](#list-of-contents)

- Clone the repository with `git clone git@github.com:athityakumar/networkx.rb.git`
- Navigate to networkx with `cd networkx.rb`
- Install dependencies with `gem install bundler && bundle install`
- Install networkx gem with `rake install`
- Start checking out in PRY / IRB console : 

```ruby
require 'networkx'
#=> true

# Yet to be implemented
g = NetworkX::Graph.new()
g.add_edge('start', 'stop')
``` 

### Roadmap

[(Back to top)](#list-of-contents)

Quite easily, any networkx user would be able to understand the number of details that have been implemented in the Python library. As a humble start towards the release of v0.1.0, the following could be the goals to achieve :

- `Node` : This class should be capable of handling different types of nodes (not just `String` / `Integer`). A possible complex use-case could be XML nodes.

- `Edge` : This class should be capable of handling different types of edges. Though a basic undirected Graph doesn't store any metadata in the edges, weighted edges and parametric edges are something that need to be handled.

- `Graph` : The simplest of graphs. This class handles just connections between different `Node`s via `Edge`s.

- `DirectedGraph` : Inherits from `Graph` class. Uses directions between `Edge`s.

### Contributing

[(Back to top)](#list-of-contents)

Your contributions are always welcome! Please have a look at the [contribution guidelines](CONTRIBUTING.md) first. :tada:

### License

[(Back to top)](#list-of-contents)

The MIT License 2017 - [Athitya Kumar](https://github.com/athityakumar). Please have a look at the [LICENSE.md](LICENSE.md) for more details.
