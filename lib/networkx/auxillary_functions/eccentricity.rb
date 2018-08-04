module NetworkX
  def self.eccentricity(graph, node=nil)
    e = {}
    graph.nodes.each do |u, _|
      length = single_source_shortest_path_length(graph, u)
      l = length.length
      raise ArgumentError, 'Found infinite path length!' unless l == graph.nodes.length
      e[u] = length.max { |x1, x2| x1[1] <=> x2[1] }[1]
    end
    node.nil? ? e : e[node]
  end

  def self.diameter(graph)
    eccentricity(graph).values.max
  end

  def self.radius(graph)
    eccentricity(graph).values.min
  end
end