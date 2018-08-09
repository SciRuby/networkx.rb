module NetworkX
  # Computes pagerank values for the graph
  #
  # @param graph [Graph, DiGraph] a graph
  # @param init [Array<Numeric>] initial pagerank values for the nodes
  # @param alpha [Numeric] the alpha value to compute the pagerank
  # @param eps [Numeric] tolerence to check for convergence
  # @param max_iter [Integer] max iterations for the pagerank algorithm to run
  #
  # @return [Array<Numeric>] pagerank values of the graph
  def self.pagerank(graph, init, alpha=0.85, eps=1e-4, max_iter=100)
    dim = graph.nodes.length
    raise ArgumentError, 'Init array needs to have same length as number of graph nodes!'\
                          unless dim == init.length
    matrix = []
    elem_ind = {}
    p = []
    curr = init.values
    init.keys.each_with_index { |n, i| elem_ind[n] = i }
    graph.adj.each do |u, u_edges|
      adj_arr = Array.new(dim, 0)
      u_edges.each do |v, _|
        adj_arr[elem_ind[v]] = 1
      end
      matrix << adj_arr
    end
    (0..(dim - 1)).each do |i|
      p[i] = []
      (0..(dim - 1)).each { |j| p[i][j] = matrix[i][j] / (matrix[i].inject(:+) * 1.0) }
    end

    max_iter.times do |_|
      prev = curr.clone
      dim.times do |i|
        ip = 0
        dim.times { |j| ip += p.transpose[i][j] * prev[j] }
        curr[i] = (alpha * ip) + (1 - alpha) / (dim * 1.0)
      end
      err = 0
      dim.times { |i| err += (prev[i] - curr[i]).abs }
      return curr if err < eps
    end
    raise ArgumentError, 'PageRank failed to converge!'
  end
end
