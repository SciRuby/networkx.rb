module NetworkX
  def hits(graph, max_iter=100, tol=1e-8, nstart)
    return [{}, {}] if graph.nodes.length == 0
    h = nstart.clone
    sum = h.values.sum
    h.each_key { |k| h[k] /= sum }
    i = 0

    while true
      hlast = h.clone
      h, a = {}, {}
      hlast.each do |k, v|
        h[k] = 0
        a[k] = 0
      end
      h.each_key { |k| graph.adj[k].each { |nbr, attrs| h[k] += a[nbr] * (attrs[:weight] || 1) } }
      smax = h.values.max
      a.each_key { |k| a[k] /= smax }
      break if h.keys.map { |k| (h[k] - hlast[k]).abs }.sum < tol
      raise ArgumentError, 'Power Iteration failed to converge!' if i > max_iter
      i += 1
    end
    [h, a]
  end

  def self.authority_matrix(graph)
    matrix, _ = to_matrix(graph)
    matrix.transpose * matrix
  end

  def self.hubs_matrix(graph)
    matrix, _ = to_matrix(graph)
    matrix * matrix.transpose
  end
end