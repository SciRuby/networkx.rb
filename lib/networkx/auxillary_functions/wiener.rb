module NetworkX
  # Returns the wiener index of the graph
  #
  # @param graph [Graph, DiGraph] a graph
  #
  # @return [Numeric] wiener index of the graph
  def self.wiener_index(graph)
    total = all_pairs_shortest_path_length(graph)
    wiener_ind = 0
    total.to_h.each { |_, distances| distances.to_h.each { |_, val| wiener_ind += val } }
    graph.directed? ? wiener_ind : wiener_ind / 2
  end
end
