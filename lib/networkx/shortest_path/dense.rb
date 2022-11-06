module NetworkX
  # Returns the all pair distance between all the nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  #
  # @return [Hash{ Object => { Object => { Numeric }}}] a hash containing distances
  #                                                     b/w all pairs of nodes
  def self.floyd_warshall(graph)
    a, index = to_matrix(graph, Float::INFINITY, 'min')
    nodelen = graph.nodes.length
    (0..(nodelen - 1)).each { |i| a[i, i] = 0 }
    (0..(nodelen - 1)).each do |k|
      (0..(nodelen - 1)).each do |i|
        (0..(nodelen - 1)).each do |j|
          a[i, j] = [a[i, j], a[i, k] + a[k, j]].min
        end
      end
    end

    as_hash = {}
    (0..(nodelen - 1)).each do |i|
      (0..(nodelen - 1)).each do |j|
        as_hash[index[i]] = {} unless as_hash.key?(index[i])
        as_hash[index[i]][index[j]] = a[i, j]
      end
    end
    as_hash
  end
end
