module NetworkX
  # Returns the eccentricity of a particular node or all nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param node [Object] node to find the eccentricity of
  #
  # @return [Array<Numeric>, Numeric] eccentricity/eccentricites of all nodes
  def self.eccentricity(graph, node=nil)
    e = {}
    graph.nodes.each do |u, _|
      length = single_source_shortest_path_length(graph, u)
      l = length.length
      raise ArgumentError, 'Found infinite path length!' unless l == graph.nodes.length

      e[u] = length.max_by { |a| a[1] }[1]
    end
    node.nil? ? e : e[node]
  end

  # Returns the diameter of a graph
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  #
  # @return [Numeric] diameter of the graph
  def self.diameter(graph)
    eccentricity(graph).values.max
  end

  # Returns the radius of a graph
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  #
  # @return [Numeric] radius of the graph
  def self.radius(graph)
    eccentricity(graph).values.min
  end
end
