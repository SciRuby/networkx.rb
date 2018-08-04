require 'rb_heap'
require 'set'

module NetworkX
  def self.get_weight(graph)
    weight_get = lambda do |_, _, attrs|
      return attrs[:weight] unless graph.multigraph?
      attrs.group_by { |_k, vals| vals[:weight] }.keys.max
    end
    weight_get
  end

  def self.help_multisource_dijkstra(graph, sources, weight, pred=nil, paths=nil, cutoff=nil, target=nil)
    count = ->(i) { i + 1 }
    i = -1
    dist = {}
    seen = {}
    fringe = Heap.new { |x, y| x[0] < y[0] || (x[0] == y[0] && x[1] < y[1]) }
    sources.each do |s|
      seen[s] = 0
      fringe << [0, count.call(i), s]
    end

    until fringe.empty?
      d, _, v = fringe.pop
      next if dist.key?(v)
      dist[v] = d
      break if v == target
      graph.adj[v].each do |u, attrs|
        cost = weight.call(v, u, attrs)
        next if cost.nil?
        vu_dist = dist[v] + cost
        next if !cutoff.nil? && vu_dist > cutoff
        if dist.key?(u)
          raise ValueError, 'Contradictory weights found!' if vu_dist < dist[u]
        elsif !seen.key?(u) || vu_dist < seen[u]
          seen[u] = vu_dist
          fringe << [vu_dist, count.call(i), u]
          paths[u] = paths[v] + [u] unless paths.nil?
          pred[u] = [v] unless pred.nil?
        elsif vu_dist == seen[u]
          pred[u] << v unless pred.nil?
        end
      end
    end
    dist
  end

  def self.help_dijkstra(graph, source, weight, pred=nil, paths=nil, cutoff=nil, target=nil)
    help_multisource_dijkstra(graph, [source], weight, pred, paths, cutoff, target)
  end

  def self.multisource_dijkstra(graph, sources, target=nil, cutoff=nil)
    raise ValueError, 'Sources cannot be empty' if sources.empty?
    return [0, [target]] if sources.include?(target)
    paths = {}
    weight = get_weight(graph)
    sources.each { |source| paths[source] = [source] }
    dist = help_multisource_dijkstra(graph, sources, weight, nil, paths, cutoff, target)
    return [dist, paths] if target.nil?
    raise KeyError, "No path to #{target}!" unless dist.key?(target)
    [dist[target], paths[target]]
  end

  def self.multisource_dijkstra_path_length(graph, sources, cutoff=nil)
    raise ValueError, 'Sources cannot be empty' if sources.empty?
    weight = get_weight(graph)
    help_multisource_dijkstra(graph, sources, weight, nil, nil, cutoff)
  end

  def self.multisource_dijkstra_path(graph, sources, cutoff=nil)
    _, path = multisource_dijkstra(graph, sources, nil, cutoff)
    path
  end

  def self.singlesource_dijkstra(graph, source, target=nil, cutoff=nil)
    multisource_dijkstra(graph, [source], target, cutoff)
  end

  def self.singlesource_dijkstra_path_length(graph, source, cutoff=nil)
    multisource_dijkstra_path_length(graph, [source], cutoff)
  end

  def self.singlesource_dijkstra_path(graph, source, cutoff=nil)
    multisource_dijkstra_path(graph, [source], cutoff)
  end

  def self.dijkstra_path_length(graph, source, target)
    return 0 if source == target
    weight = get_weight(graph)
    length = help_dijkstra(graph, source, weight, nil, nil, nil, target)
    raise KeyError, 'Node not reachable!' unless length.key?(target)
    length[target]
  end

  def self.dijkstra_path(graph, source, target)
    _, path = singlesource_dijkstra(graph, source, target)
    path
  end

  def self.dijkstra_predecessor_distance(graph, source, cutoff=nil)
    weight = get_weight(graph)
    pred = {source => []}
    [pred, help_dijkstra(graph, source, weight, pred, nil, cutoff)]
  end

  def self.all_pairs_dijkstra(graph, cutoff=nil)
    path = []
    graph.nodes.each_key { |n| path << [n, singlesource_dijkstra(graph, n, nil, cutoff)] }
    path
  end

  def self.all_pairs_dijkstra_path_length(graph, cutoff=nil)
    path_lengths = []
    graph.nodes.each_key { |n| path_lengths << [n, singlesource_dijkstra_path_length(graph, n, cutoff)] }
    path_lengths
  end

  def self.all_pairs_dijkstra_path(graph, cutoff=nil)
    paths = []
    graph.nodes.each_key { |n| paths << singlesource_dijkstra_path(graph, n, cutoff) }
    paths
  end

  def self.help_bellman_ford(graph, sources, weight, pred=nil, paths=nil, dist=nil, cutoff=nil, target=nil)
    pred = sources.product([[]]).to_h if pred.nil?
    dist = sources.product([0]).to_h if dist.nil?

    inf, n, count, q, in_q = Float::INFINITY, graph.nodes.length, {}, sources.clone, Set.new(sources)
    until q.empty?
      u = q.shift
      in_q.delete(u)
      skip = false
      pred[u].each { |k| skip = true if in_q.include?(k) }
      next if skip
      dist_u = dist[u]
      graph.adj[u].each do |v, e|
        dist_v = dist_u + weight.call(u, v, e)
        next if !cutoff.nil? && dist_v > cutoff
        next if !target.nil? && dist_v > (dist[target] || inf)
        if dist_v < (dist[v] || inf)
          unless in_q.include?(v)
            q << v
            in_q.add(v)
            count_v = (count[v] || 0) + 1
            raise ArgumentError, 'Negative edge cycle detected!' if count_v == n
            count[v] = count_v
          end
          dist[v] = dist_v
          pred[v] = [u]
        elsif dist.key?(v) && dist_v == dist[v]
          pred[v] << u
        end
      end
    end
    unless paths.nil?
      dsts = target.nil? ? pred : [target]
      dsts.each_key do |dst|
        path, cur = [dst], dst
        until pred[cur][0].nil?
          cur = pred[cur][0]
          path << cur
        end
        path.reverse
        paths[dst] = path
      end
    end
    dist
  end

  def self.bellmanford_predecesor_distance(graph, source, target=nil, cutoff=nil)
    raise ArgumentError, 'Node not found!' unless graph.node?(source)
    weight = get_weight(graph)
    # TODO: Detection of selfloop edges
    dist = {source => 0}
    pred = {source => []}
    return [pred, dist] if graph.nodes.length == 1
    dist = help_bellman_ford(graph, [source], weight, pred, nil, dist, cutoff, target)
    [pred, dist]
  end

  def self.singlesource_bellmanford(graph, source, target=nil, cutoff=nil)
    return [0, [source]] if source == target
    weight = get_weight(graph)
    paths = {source => [source]}
    dist = help_bellman_ford(graph, [source], weight, nil, paths, nil, cutoff, target)
    return [dist, paths] if target.nil?
    raise ArgumentError, 'Node not reachable!' unless dist.key?(target)
    [dist[target], paths[target]]
  end

  def self.bellmanford_path_length(graph, source, target)
    return 0 if source == target
    weight = get_weight(graph)
    length = help_bellman_ford(graph, [source], weight, nil, nil, nil, nil, target=target)
    raise ArgumentError, 'Node not reachable!' unless length.key?(target)
    length[target]
  end

  def self.bellmanford_path(graph, source, target)
    _, path = singlesource_bellmanford(graph, source, target)
    path
  end

  def self.singlesource_bellmanford_path(graph, source, cutoff=nil)
    _, path = singlesource_bellmanford(graph, source, cutoff)
    path
  end

  def self.singlesource_bellmanford_path_length(graph, source, cutoff=nil)
    weight = get_weight(graph)
    help_bellman_ford(graph, [source], weight, nil, nil, nil, cutoff)
  end

  def self.allpairs_bellmanford_path_length(graph, cutoff=nil)
    path_lengths = []
    graph.nodes.each_key { |n| path_lengths << [n, singlesource_bellmanford_path_length(graph, n, cutoff)] }
    path_lengths
  end

  def self.allpairs_bellmanford_path(graph, cutoff=nil)
    paths = []
    graph.nodes.each_key { |n| paths << [n, singlesource_bellmanford_path(graph, n, cutoff)] }
    paths
  end

  def self.goldberg_radzik(_graph, _source)
    raise NotImplementedError, 'Not yet implemented!'
  end

  def self.get_sources(graph)
    graph.nodes.collect { |k, _v| k }
  end

  def self.dist_path_lambda(graph, new_weight)
    lambda do |v|
      paths = {v => [v]}
      _ = help_dijkstra(graph, v, new_weight, paths=paths)
      paths
    end
  end

  def self.set_path_lengths_johnson(graph, dist_path)
    path_lengths = []
    graph.nodes.each_key { |n| path_lengths << [n, dist_path.call(n)] }
    path_lengths
  end

  def self.johnson(graph)
    dist, pred = {}, {}
    sources = get_sources(graph)
    graph.nodes.each_key do |n|
      dist[n], pred[n] = 0, []
    end
    weight = get_weight(graph)
    dist_bellman = help_bellman_ford(graph, sources, weight, pred, nil, dist=dist)
    new_weight = ->(u, v, d) { weight.call(d) + dist_bellman[u] - dist_bellman[v] }
    dist_path = dist_path_lambda(graph, new_weight)
    path_lengths = set_path_lengths_johnson(graph, dist_path)
    path_lengths
  end
end
