require_relative '../graph'

class Array
  include Comparable
end

# Reference: https://networkx.org/documentation/stable/_modules/networkx/generators/lattice.html#grid_2d_graph
module NetworkX
  # @param m [Integer] the number of rows
  # @param n [Integer] the number of columns
  # @param create_using [Class] graph class. this is optional. default is `NetworkX::Graph`.
  def self.grid_2d_graph(m, n, periodic: false, create_using: NetworkX::Graph)
    warn('sorry, periodic is not done yet') if periodic

    m.is_a?(Integer) or raise(ArgumentError, "[NetworkX] argument m: Integer, not #{m.class}")
    n.is_a?(Integer) or raise(ArgumentError, "[NetworkX] argument n: Integer, not #{n.class}")
    create_using.is_a?(Class) \
      or raise(ArgumentError, "[NetworkX] argument create_using: `Graph` class or children, not #{create_using.class}")

    g = create_using.new

    a = []
    m.times { |i| n.times { |j| a << [i, j] } }
    g.add_nodes_from(a)

    e1 = []
    (m - 1).times { |i| n.times { |j| e1 << [[i, j], [i + 1, j]] } }
    g.add_edges_from(e1)

    e2 = []
    m.times { |i| (n - 1).times { |j| e2 << [[i, j], [i, j + 1]] } }
    g.add_edges_from(e2)

    g.add_edges_from(g.edges.map { |i, j| [j, i] }) if g.directed?

    g
  end
end
