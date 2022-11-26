module NetworkX
  # Computes pagerank values for the graph
  #
  # @param graph [Graph] a graph
  # @param alpha [Numeric] the alpha value to compute the pagerank
  # @param eps [Numeric] tolerence to check for convergence
  # @param max_iter [Integer] max iterations for the pagerank algorithm to run
  #
  # @return [Hash of Object => Float] pagerank values of the graph
  def self.pagerank(graph, alpha: 0.85, personalization: nil, eps: 1e-6, max_iter: 100)
    n = graph.number_of_nodes

    matrix, index_to_node = NetworkX.to_matrix(graph, 0)

    index_from_node = index_to_node.invert

    probabilities = Array.new(n) do |i|
      total = matrix.row(i).sum
      (matrix.row(i) / total.to_f).to_a
    end

    curr = personalization
    unless curr
      curr = Array.new(n)
      graph.each_node{|node| curr[index_from_node[node]] = 1.0 / n }
    end

    max_iter.times do
      prev = curr.clone

      n.times do |i|
        ip = 0.0
        n.times do |j|
          ip += probabilities[j][i] * prev[j]
        end
        curr[i] = (alpha * ip) + ((1.0 - alpha) / n * 1.0)
      end

      err = (0...n).map{|i| (prev[i] - curr[i]).abs }.sum
      return (0...n).map{|i| [index_to_node[i], curr[i]] }.sort.to_h if err < eps
    end
    warn "pagerank() failed within #{max_iter} iterations. Please inclease max_iter: or loosen eps:"
    (0...n).map{|i| [index_to_node[i], curr[i]] }.sort.to_h
  end
end
