module NetworkX
  # Returns the closeness vitality of a node
  #
  # @param graph [Graph, DiGraph] a graph
  # @param node [Object] node to compute closeness vitality of
  #
  # @return [Numeric] closeness vitality of the given node
  def self.closeness_vitality(graph, node)
    before = wiener_index(graph)
    after = wiener_index(graph.subgraph(graph.nodes.keys - [node]))
    before - after
  end
end
