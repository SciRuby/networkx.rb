module NetworkX
  def network_simplex(graph)
    node_indices = Hash[graph.nodes.keys.each_with_index.map { |k, i| [k, i] }]
    node_demands = graph.nodes.values.map { |attrs| attrs[:demand] || 0] }
    inf = Float::INFINITY

    raise NotImplementedError, 'NetworkSimplex algorithm has not been implemented for Undirected graphs!' unless graph.directed?
    raise ArgumentError, 'A node has infinite demand!' if graph.nodes.values.include?(inf)

    sources = []
    targets = []
    keys = [] if graph.multigraph?
    edge_indices = {}
    edge_capacities = []
    edge_weights = []
    edges = []
    graph.adj.each do |u, u_edges|
      u_edges.each do |v, uv_attrs|
        if graph.multigraph?
          uv_attrs.each { |k, attrs| edges << [u, v, attrs, k] }
        else
          edges << [u, v, uv_attrs]
      end
    end
    edges.each_with_index do |i, (u, v, attrs, k)|
      sources << [node_indices[u]]
      targets << [node_indices[v]]
      keys << [k] if graph.multigraph?
      edge_indices[edges[i]] = i
      raise ArgumentError, 'Edge has negative capacity!' if attrs[:capacity] < 0
      edge_capacities << [attrs[:capacity] || inf]
      raise ArgumentError, 'Edge has infinite weight!' if abs(attrs[:weight]) == inf
      edge_weights << [attrs[:weight] || 0]
    end
    # TODO: Inclusion of selfloop edges
    raise ArgumentError, 'Total node demand is not zero!' unless node_demands.sum == 0

    n = graph.nodes.length
    node_demands.each_with_index do |p, d|
      if d > 0
        sources << -1
        targets << p
      else
        sources << p
        targets << -1
      end
    end
    faux_max = 3 * ([edge_capacities.inject(0) { |sum, x| sum += x if x < inf }, edge_weights.inject(0) { |sum, weight| sum += weight.abs }] + node_demands.map { |d| d.abs }).sum
    edge_weights += Array.new(n, faux_max)
    edge_capacities += Array.new(n, faux_max)

    e = edges.length
    x = Array.new(e, 0) + node_demands.map { |d| d.abs }
    pi = node_demands.map { |d| d.abs * -1 }
    parent = Array.new(n, -1) + [nil]
    edge = Array.new(e..(e + n - 1))
    size = Array.new(n, 1) + [n + 1]
    next_node = Array.new(1..(n - 1)) + [-1, 0]
    prev_node = Array.new(-1..(n - 1))
    last = Array.new(0..(n - 1))

    find_entering_edges.each do |i, p, q|
      wn, we = find_cycle(i, p, q)
      j, s, t = find_leaving_edge(wn, we)
      augment_flow(wn, we, residual_capacity(j, s))
      unless i == j
        s, t = t, s unless parent[t] == s
        p, q = q, p if we.index(i) > we.index(j)
        remove_edge(s, t)
        make_root(q)
        add_edge(i, p, q)
        update_potentials(i, p, q)
      end
    end

    (-n..-1).each { |idx| raise ArgumentError, 'No flow satisfies all node demands' unless x[idx] == 0 }
    # TODO: condition on self loop edges

    x.slice!(e..-1)
    flow_cost = edge_weights.zip(x).map { |c_i, x_i| c_i * x_i }.sum
    flow_dict = Hash[graph.nodes.keys.map { |node| [node, {}] }]

    souces = sources.map { |node| graph.nodes.keys[node] }
    targets = targets.map { |node| graph.nodes.keys[node] }

    sources.zip(targets, x).each { |e| add_entry(e) } unless graph.multigraph?
    sources.zip(targets, keys, x).each { |e| add_entry(e) } if graph.multigraph?

    edges.each do |e|
      if e[0] != e[1]
        add_entry
    end

  end

  def add_entry(e)
    d = flow_dict[e[0]]
    e[1..-3].each do |k|
      begin
        d = d[k]
      rescue
        t = {}
        d[k] = t
        d = t
      end
    end
    d[e[-2]] = e[-1]
  end

  def reduce_cost(edge_weights, pi, sources, targets, x, i)
    c = edge_weights[i] - pi[sources[i]] + pi[targets[i]]
    x[i] == 0 ? c : -c
  end

  def find_entering_edges()
    return if e == 0
    bsize = Math.sqrt(n).ceil
    m_consecutive = ((e + bsize - 1) / bsize).floor
    m = 0
    first_edge = 0
    enr = Enumerator.new do |enr|
      while m < m_consecutive
        l = first_edge + bsize
        if l <= e
          edges = Array.new(f..(l - 1))
        else
          l -= e
          edges = Array.new(f..(e - 1)) + Array.new(0..(l - 1))
        end
        first_edge = l
        i = edges.map { |edg| [reduced_cost(edge_weights, pi, sources, targets, x, edg), edg] }.min.last
        c = reduce_cost(edge_weights, pi, sources, targets, x, i)
        if c >= 0
          m += 1
        else
          p, q = x[i] == 0 ? (sources[i], targets[i]) : (targets[i], sources[i])
        end
        enr.yeild i, p, q
        m = 0
      end
    end
    # TODO
    return enr
  end

  def find_apex(p, q)
    size_p = size[p]
    size_q = size[q]
    while true
      while size_p < size_q
        p = parent[p]
        size_p = size[p]
        while size_p > size_q
          q = parent_q
          size_q = size[q]
        end
        if size_p == size_q
          if p != q
            p = parent[p]
            size_p = size[p]
            q = parent_q
            size_q = size[q]
          else
            return p
          end
        end
      end
    end
  end

  def trace_path(p, w)
    wn = [p]
    we = []
    while p != q
      we << edge[p]
      p = parent[p]
      wn << p
    end
    wn, we
  end

  def find_cycle(i, p, q)
    w = find_apex(p, q)
    wn, we = trace_path(p, w)
    wn.reverse!
    we.reverse!
    we << i
    wnr, wer = trace_path(q, w)
    wnr.pop
    wn += wnr
    we += wer
    wn, we
  end

  def residual_capacity(i, p)
    sources[i] == p ? edge_capacities[i] - x[i] : x[i]
  end

  def find_leaving_edge(wn, we)
    j, s = we.zip(wn).map { |we_i, wn_i| [residual_capacity(we_i, wn_i), [we_i, wn_i]] }.min.last
    t = sources[j] == s ? targets[j] : sources[j]
    j, s, t
  end

  def augment_flow(wn, we, f)
    we.zip(wn).each { |we_i, wn_i| x[we_i] += (sources[we_i] == wn_i ? f : -f) }
  end

  def trace_subtree(p)
    enr = Enumerator.new do |enr|
      enr.yeild p
      l = last[p]
      while p != l
        p = next[p]
        enr.yeild p
      end
    end
    # TODO
  end

  def remove_edge(s, t)
    size_t = size[t]
    prev_t = prev[t]
    last_t = last[t]
    next_last_t = next_node[last_t]

    parent[t] = nil
    edge[t] = nil

    next_node[prev_t] = next_last_t
    prev[next_last_t] = prev_t
    next_node[last_t] = t
    prev[t] = last_t

    while !s.nil?
      size[s] -= size_t
      last[s] = prev_t if last[s] == last_t
      s = parent[s]
    end
  end

  def make_root(q)
    ancestors = []
    while !q.nil?
      ancestors << q
      q = parent[1]
    ancestors.reverse!
    ancestors[1..-1].zip(ancestors).each do |p, q|
      size_p = size[p]
      last_p = last[p]
      prev_q = prev[q]
      last_q = last[q]
      next_last_q = next_node[last_q]
      parent[p] = q
      parent[q] = nil
      edge[p] = edge[q]
      edge[q] = nil
      size[p] = size_p - size[q]
      size[q] = size_p
      next_node[prev_q] = next_last_q
      prev[next_last_q] = prev_q
      next_node[last_q] = q
      prev[q] = last_q
      last[p], last_p = prev_q, prev_q if last_p == last_q
      prev[p] = last_q
      next_node[last_q] = p
      next_node[last_p] = q
      prev[q] = last_p
      last[q] = last_p
    end
  end

  def add_edge(i, p, q)
    last_p = last[p]
    next_last_p = next_node[last_p]
    size_q = size[q]
    last_q = last[q]
    parent[q] = p
    edge[q] = i
    next_node[last_p] = q
    prev[q] = last_p
    prev[next_last_p] = last_q
    next_node[last_q] = next_last_p

    while !p.nil?
      size[p] += size_q
      last[p] = last_q if last[p] == last_p
      p = parent[p]
    end
  end

  def update_potentials(i, p, q)
    d = q == targets[i] ? pi[p] - edge_weights[i] - pi[q]
    trace_subtree(q).each { |q_i| pi[q_i] += d }
  end
end