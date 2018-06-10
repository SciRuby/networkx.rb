require 'rb_heap'
require 'set'
require 'pry'

module NetworkX
  def self.get_weight(g)
    weight_get = ->(attrs) do
      return attrs[:weight] unless g.is_multigraph
      attrs.group_by { |k, vals| vals[:weight] }.keys.max
    end
    weight_get
  end

  def self.help_multisource_dijkstra(g, sources, weight, pred=nil, paths=nil, cutoff=nil, target=nil)
    # binding.pry
    count = ->(i) { i + 1 }
    i = -1
    dist = {}
    seen = {}
    fringe = Heap.new{ |x, y| x[0] < y[0] || (x[0] == y[0] && x[1] < y[1]) }
    sources.each do |s|
      seen[s] = 0
      fringe << [0, count.call(i), s]
    end

    while !fringe.empty?
      d, _, v = fringe.pop
      next if dist.key?(v)
      dist[v] = d
      break if v == target
      g.adj[v].each do |u, attrs|
        cost = weight.call(attrs)
        next if cost.nil?
        vu_dist = dist[v] + cost
        #  binding.pry
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

  def self.help_dijkstra(g, source, weight, pred=nil, paths=nil, cutoff=nil, target=nil)
    self.help_multisource_dijkstra(g, [source], weight, pred, paths, cutoff, target)
  end

  def self.multisource_dijkstra(g, sources, target=nil, cutoff=nil)
    raise ValueError, 'Sources cannot be empty' if sources.empty?
    return [0 , [target]] if sources.include?(target)
    paths = {}
    weight = get_weight(g)
    # binding.pry
    sources.each { |source| paths[source] = [source] }
    dist = help_multisource_dijkstra(g, sources, weight, nil, paths=paths, cutoff=cutoff, target=target)
    return [dist, paths] if target.nil?
    raise KeyError, "No path to #{target}!" unless dist.key?(target)
    [dist[target], paths[target]]
  end

  def self.multisource_dijkstra_path_length(g, sources, cutoff=nil)
    raise ValueError, 'Sources cannot be empty' if sources.empty?
    weight = get_weight(g)
    self.help_multisource_dijkstra(g, sources, weight, nil, nil, cutoff)
  end

  def self.multisource_dijkstra_path(g, sources, cutoff=nil)
    length, path = multisource_dijkstra(g, sources, nil, cutoff)
    path
  end

  def self.singlesource_dijkstra(g, source, target=nil, cutoff=nil)
    multisource_dijkstra(g, [source], target, cutoff)
  end

  def self.singlesource_dijkstra_path_length(g, source, cutoff=nil)
    multisource_dijkstra_path_length(g, [source], cutoff)
  end

  def self.singlesource_dijkstra_path(g, source, cutoff=nil)
    multisource_dijkstra_path(g, [source], cutoff)
  end

  def self.dijkstra_path_length(g, source, target)
    return 0 if source == target
    weight = get_weight(g)
    length = help_dijkstra(g, source, weight, nil, nil, nil, target)
    raise KeyError, 'Node not reachable!' unless length.key?(target)
    length[target]
  end

  def self.dijkstra_path(g, source, target)
    _, path = singlesource_dijkstra(g, source, target)
    path
  end

  def self.dijkstra_predecessor_distance(g, source, cutoff=nil)
    weight = get_weight(g)
    pred = {source => []}
    [pred, help_dijkstra(g, source, weight, pred, nil, cutoff)]
  end

  def self.all_pairs_dijkstra(g, cutoff=nil)
    path = []
    g.nodes.each_key { |n| path << [n, singlesource_dijkstra(g, n, nil, cutoff)] }
    path
  end

  def self.all_pairs_dijkstra_path_length(g, cutoff=nil)
    path_lengths = []
    g.nodes.each_key { |n| path_lengths << [n, singlesource_dijkstra_path_length(g, n, cutoff)] }
    path_lengths
  end

  def self.all_pairs_dijkstra_path(g, cutoff=nil)
    paths = []
    g.nodes.each_key { |n| paths << singlesource_dijkstra_path(g, n, cutoff) }
    paths
  end

  def self.help_bellman_ford(g, sources, weight, pred=nil, paths=nil, dist=nil, cutoff=nil, target=nil)
    if pred.nil?
      pred = {}
      sources.each do |s|
        pred[s] = []
      end
    end

    if dist.nil?
      dist = {}
      sources.each do |s|
        dist[s] = 0
      end
    end

    inf = Float::INFINITY
    n = g.nodes.length
    count = {}
    q = sources.clone
    in_q = Set.new(sources)
    while !q.empty?
      u = q.shift
      # binding.pry
      in_q.delete(u)
      skip = false
      pred[u].each { |k| skip = true if in_q.include?(k) }
      if !skip
        dist_u = dist[u]
        g.adj[u].each do |v, e|
          dist_v = dist_u + weight.call(e)
          next if !cutoff.nil? && dist_v > cutoff
          next if !target.nil? && dist_v > (dist[target] || inf)
          if dist_v < (dist[v] || inf)
            if !in_q.include?(v)
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
    end
    unless paths.nil?
      dsts = target.nil? ? pred : [target]
      dsts.each_key do |dst|
        path = [dst]
        cur = dst
        # binding.pry
        while !pred[cur][0].nil?
          cur = pred[cur][0]
          path << cur
        end
        path.reverse
        paths[dst] = path
      end
    end
    dist
  end

  def self.bellmanford_predecesor_distance(g, source, target=nil, cutoff=nil)
    raise ArgumentError, 'Node not found!' unless g.node?(source)
    weight = get_weight(g)
    # TODO: Detection of selfloop edges
    dist = {source => 0}
    pred = {source => []}
    return [pred, dist] if g.nodes.length == 1
    dist = help_bellman_ford(g, [source], weight, pred, nil, dist, cutoff, target)
    [pred, dist]
  end

  def self.singlesource_bellmanford(g, source, target=nil, cutoff=nil)
    return [0, [source]] if source == target
    weight = get_weight(g)
    paths = {source => [source]}
    dist = help_bellman_ford(g, [source], weight, nil, paths, nil, cutoff, target)
    return [dist, paths] if target.nil?
    raise ArgumentError, 'Node not reachable!' unless dist.key?(target)
    [dist[target], paths[target]]
  end

  def self.bellmanford_path_length(g, source, target)
    return 0 if source == target
    weight = get_weight(g)
    length = help_bellman_ford(g, [source], weight, nil, nil, nil, nil, target=target)
    raise ArgumentError, 'Node not reachable!' unless length.key?(target)
    length[target]
  end

  def self.bellmanford_path(g, source, target)
    length, path = singlesource_bellmanford(g, source, target)
    path
  end

  def self.singlesource_bellmanford_path(g, source, cutoff=nil)
    length, path = singlesource_bellmanford(g, source, cutoff=cutoff)
    path
  end

  def self.singlesource_bellmanford_path_length(g, source, cutoff=nil)
    weight = get_weight(g)
    help_bellman_ford(g, [source], weight, nil, nil, nil, cutoff)
  end

  def self.allpairs_bellmanford_path_length(g, cutoff=nil)
    path_lengths = []
    g.nodes.each_key { |n| path_lengths << [n, singlesource_bellmanford_path_length(g, n, cutoff)] }
    path_lengths
  end

  def self.allpairs_bellmanford_path(g, cutoff=nil)
    paths = []
    g.nodes.each_key { |n| paths << [n, singlesource_bellmanford_path(g, n, cutoff)] }
    paths
  end

  def self.goldberg_radzik(g, source)
    raise NotImplementedError, 'Not yet implemented!'
  end

  def self.johnson(g)
    dist = {}
    path_lengths = []
    pred = {}
    sources = g.nodes.collect { |k, v| k }
    g.nodes.each_key do |n|
      dist[n] = 0
      pred[n] = []
    end
    weight = get_weight(g)
    dist_bellman = help_bellman_ford(g, sources, weight, pred, nil, dist=dist)
    new_weight = ->(d) { weight.call(d) + dist_bellman[u] - dist_bellman[v] }
    dist_path = ->(v) do
      paths = {v => [v]}
      _ = help_dijkstra(g, v, new_weight, paths=paths)
      paths
    end
    g.nodes.each_key { |n| path_lengths << [n, dist_path.call(n)] }
    path_lengths
  end
end
