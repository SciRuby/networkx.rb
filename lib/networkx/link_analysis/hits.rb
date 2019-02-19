module NetworkX
  # TODO: Reduce method length and method complexity

  # Computes hits and authority scores for all the graphs
  #
  # @param graph [Graph, DiGraph] a graph
  # @param max_iter [Integer] max iterations to run the hits algorithm
  # @param tol [Numeric] tolerences to cut off the loop
  # @param nstart [Array<Numeric>] starting hub values for the nodes
  #
  # @return [Array<Numeric, Numeric>] hits and authority scores
  def self.hits(graph, max_iter=100, tol=1e-8, nstart)
    return [{}, {}] if graph.nodes.empty?

    h = nstart
    sum = h.values.inject(:+)
    h.each_key { |k| h[k] /= (sum * 1.0) }
    i = 0
    a = {}

    loop do
      hlast = Marshal.load(Marshal.dump(h))
      h, a = {}, {}
      hlast.each do |k, _v|
        h[k] = 0
        a[k] = 0
      end
      h.each_key { |k| graph.adj[k].each { |nbr, attrs| a[k] += hlast[nbr] * (attrs[:weight] || 1) } }
      h.each_key { |k| graph.adj[k].each { |nbr, attrs| h[k] += a[nbr] * (attrs[:weight] || 1) } }
      smax = h.values.max
      h.each_key { |k| h[k] /= smax }
      smax = a.values.max
      a.each_key { |k| a[k] /= smax }
      break if h.keys.map { |k| (h[k] - hlast[k]).abs }.inject(:+) < tol
      raise ArgumentError, 'Power Iteration failed to converge!' if i > max_iter

      i += 1
    end
    [h, a]
  end

  # Computes authority matrix for the graph
  #
  # @param graph [Graph, DiGraph] a graph
  #
  # @return [NMatrix] authority matrix for the graph
  def self.authority_matrix(graph)
    matrix, = to_matrix(graph, 0)
    matrix.transpose.dot matrix
  end

  # Computes hub matrix for the graph
  #
  # @param graph [Graph, DiGraph] a graph
  #
  # @return [NMatrix] hub matrix for the graph
  def self.hub_matrix(graph)
    matrix, = to_matrix(graph, 0)
    matrix.dot matrix.transpose
  end
end
