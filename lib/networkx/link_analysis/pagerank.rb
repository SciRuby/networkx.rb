module NetworkX
  # Computes pagerank values for the graph
  #
  # @param graph [Graph] a graph
  # @param init [Array<Numeric>] initial pagerank values for the nodes
  # @param alpha [Numeric] the alpha value to compute the pagerank
  # @param eps [Numeric] tolerence to check for convergence
  # @param max_iter [Integer] max iterations for the pagerank algorithm to run
  #
  # @return [Array<Numeric>] pagerank values of the graph
  def self.pagerank(graph, init = nil, alpha = 0.85, eps = 1e-4, max_iter = 100)
    dim = graph.nodes.length
    if init.nil?
      init = graph.nodes(data: false).to_h{ |i| [i, 1.0 / dim] }
    else
      s = init.values.sum.to_f
      init = init.transform_values { |v| v / s }
    end
    raise ArgumentError, 'Init array needs to have same length as number of graph nodes!' \
                          unless dim == init.length

    matrix = []
    elem_ind = {}
    p = []
    curr = init.values
    init.keys.each_with_index { |n, i| elem_ind[n] = i }
    graph.adj.each do |_u, u_edges|
      adj_arr = Array.new(dim, 0)
      u_edges.each do |v, _|
        adj_arr[elem_ind[v]] = 1
      end
      matrix << adj_arr
    end
    (0..(dim - 1)).each do |i|
      p[i] = []
      (0..(dim - 1)).each { |j| p[i][j] = matrix[i][j] / (matrix[i].sum * 1.0) }
    end

    max_iter.times do |_|
      prev = curr.clone
      dim.times do |i|
        ip = 0
        dim.times { |j| ip += p.transpose[i][j] * prev[j] }
        curr[i] = (alpha * ip) + ((1 - alpha) / (dim * 1.0))
      end
      err = 0
      dim.times { |i| err += (prev[i] - curr[i]).abs }
      return curr if err < eps
    end
    raise ArgumentError, 'PageRank failed to converge!'
  end

  def self.pagerank2(graph, alpha: 0.85, personalization: nil, eps: 1e-6, max_iter: 100)
    n = graph.number_of_nodes

    matrix, index_to_node = NetworkX.to_matrix(graph, 0)

    # index_to_node = {0=>0, 1=>1, 2=>2, 3=>3}

    index_from_node = index_to_node.invert

    probabilities = Array.new(n) do |i|
      total = matrix.row(i).sum
      (matrix.row(i) / total.to_f).to_a
    end

    unless curr = personalization
      curr = Array.new(n)
      graph.nodes(data: false).each{|node| curr[index_from_node[node]] = 1.0 / n }
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
    (0...n).map{|i| [index_to_node[i], curr[i]] }.sort.to_h
  end
end
