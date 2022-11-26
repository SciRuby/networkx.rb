module NetworkX
  # Performs the complement operation on the graph
  #
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the complement of the graph
  def self.complement(graph)
    result = Marshal.load(Marshal.dump(graph))
    result.clear

    result.add_nodes(graph.nodes(data: true).map { |u, attrs| [u, attrs] })
    graph.adj.each do |u, u_edges|
      graph.nodes(data: true).each { |v, attrs| result.add_edge(u, v, **attrs) if !u_edges.has_key?(v) && u != v }
    end
    result
  end
end
