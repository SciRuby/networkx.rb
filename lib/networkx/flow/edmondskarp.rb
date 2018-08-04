module NetworkX
  def self.augment(residual, inf, path)
    flow = inf
    path_first_elem = path.shift
    u = path_first_elem
    path.each do |v|
      flow = [flow, residual.adj[u][v][:capacity] - residual.adj[u][v][:flow]].min
      u = v
    end
    raise ArgumentError, 'Infinite capacity path!' if flow * 2 > inf
    u = path_first_elem
    path.each do |v|
      residual.adj[u][v][:flow] += flow
      residual.adj[v][u][:flow] -= flow
      u = v
    end
    flow
  end

  def self.bidirectional_bfs(residual, source, target)
    pred, succ = {source => nil}, {target => nil}
    q_s, q_t = [source], [target]
    loop do
      q = []
      if q_s.length <= q_t.length
        q_s.each do |u|
          residual.adj[u].each do |v, uv_attrs|
            next unless !pred.include?(v) && (uv_attrs[:flow] < uv_attrs[:capacity])
            pred[v] = u
            return [v, pred, succ] if succ.key?(v)
            q << v
          end
        end
        return [nil, nil, nil] if q.empty?
      else
        q_t.each do |u|
          residual.pred[u].each do |v, uv_attrs|
            next unless !succ.key?(v) && uv_attrs[:flow] < uv_attrs[:capacity]
            succ[v] = u
            return [v, pred, succ] if pred.key?(v)
            q << v
          end
        end
        return [nil, nil, nil] if q.empty?
        q_t = q
      end
    end
  end

  def self.edmondskarp_core(residual, source, target, cutoff)
    inf = residual.graph[:inf]
    flow_val = 0
    while flow_val < cutoff
      v, pred, succ = bidirectional_bfs(residual, source, target)
      break if pred.nil?
      path = [v]
      u = v
      while u != source
        u = pred[u]
        path << u
      end
      path.reverse!
      u = v
      while u != target
        u = succ[u]
        path << u
      end
      flow_val += augment(path)
    end
    flow_val
  end

  def self.edmondskarp_impl(graph, source, target, residual, cutoff)
    raise ArgumentError, 'Source not in graph!' unless graph.nodes.key?(source)
    raise ArgumentError, 'Target not in graph!' unless graph.nodes.key?(target)
    raise ArgumentError, 'Source and target are same node!' if source == target
    res_graph = residual.nil? ? build_residual_network(graph) : residual.clone
    res_graph.adj.each do |u, u_edges|
      u_edges.each do |v, _attrs|
        res_graph.adj[u][v][:flow] = 0
        res_graph.pred[v][u][:flow] = 0
      end
    end
    cutoff = Float::INFINITY if cutoff.nil?
    res_graph.graph[:flow_val] = edmondskarp_core(res_graph, source, target, cutoff)
    res_graph
  end

  def self.edmondskarp(graph, source, target, residual=nil, cutoff=nil)
    edmondskarp_impl(graph, source, target, residual, cutoff)
  end
end
