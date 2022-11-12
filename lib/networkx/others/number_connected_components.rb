require_relative '../graph'
require_relative '../auxillary_functions/union_find'

module NetworkX
  # @param [NetworkX::Graph] graph
  #
  # @return [Integer] the number of connected components on graph
  def self.number_connected_components(graph)
    uf = NetworkX::UnionFind.new(graph.nodes(data: false))
    graph.each_edge { |x, y| uf.unite(x, y) }
    uf.groups.size
  end

  class << self
    alias number_of_connected_components number_connected_components
  end
end
