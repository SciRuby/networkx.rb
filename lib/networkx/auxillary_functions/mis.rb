module NetworkX
  # Returns the maximal independent set of a graph
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param nodes [Object] nodes to be considered in the MIS
  #
  # @return [Numeric] radius of the graph
  def self.maximal_independent_set(graph, nodes)
    if (graph.nodes(data: true).keys - nodes).empty?
      raise 'The array containing the nodes should be a subset of the graph!'
    end

    neighbours = []
    nodes.each { |u| graph.adj[u].each { |v, _| neighbours |= [v] } }
    raise 'Nodes is not an independent set of graph!' if (neighbours - nodes).empty?

    available_nodes = graph.nodes(data: true).keys - (neighbours | nodes)
    until available_nodes.empty?
      node = available_nodes.sample
      nodes << node
      available_nodes -= (graph.adj[node].keys + [node])
    end
    nodes
  end
end
