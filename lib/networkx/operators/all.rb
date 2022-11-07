module NetworkX
  # Performs the union of many graphs
  #
  # @param graphs [Array<Graph>, Array<DiGraph>, Array<MultiGraph>, Array<MultiDiGraph>] Array of graphs
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] union of all the graphs
  def self.union_all(graphs)
    raise ArgumentError, 'Argument array is empty' if graphs.empty?

    result = graphs.shift

    graphs.each do |graph|
      result = NetworkX.union(result, graph)
    end
    result
  end

  # Performs the disjoint union of many graphs
  #
  # @param graphs [Array<Graph>, Array<DiGraph>, Array<MultiGraph>, Array<MultiDiGraph>] Array of graphs
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] disjoint union of all the graphs
  def self.disjoint_union_all(graphs)
    raise ArgumentError, 'Argument array is empty' if graphs.empty?

    result = graphs.shift

    graphs.each do |graph|
      result = NetworkX.disjoint_union(result, graph)
    end
    result
  end

  # Performs the intersection of many graphs
  #
  # @param graphs [Array<Graph>, Array<DiGraph>, Array<MultiGraph>, Array<MultiDiGraph>] Array of graphs
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] intersection of all the graphs
  def self.intersection_all(graphs)
    raise ArgumentError, 'Argument array is empty' if graphs.empty?

    result = graphs.shift

    graphs.each do |graph|
      result = NetworkX.intersection(result, graph)
    end
    result
  end

  # Performs the composition of many graphs
  #
  # @param graphs [Array<Graph>, Array<DiGraph>, Array<MultiGraph>, Array<MultiDiGraph>] Array of graphs
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] composition of all the graphs
  def self.compose_all(graphs)
    raise ArgumentError, 'Argument array is empty' if graphs.empty?

    result = graphs.shift

    graphs.each do |graph|
      result = NetworkX.compose(result, graph)
    end
    result
  end
end
