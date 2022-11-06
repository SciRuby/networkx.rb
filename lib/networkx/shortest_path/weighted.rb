# frozen_string_literal: true

# TODO: Reduce module length

module NetworkX
  # Helper function to extract weight from a adjecency hash
  def self.get_weight(graph)
    lambda do |_, _, attrs|
      return attrs[:weight] || 1 unless graph.multigraph?

      attrs.group_by { |_k, vals| vals[:weight] || 1 }.keys.max
    end
  end

  # TODO: Reduce method length and method complexity

  # Helper function for multisource dijkstra
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

  # Helper function for single source dijkstra
  def self.help_dijkstra(graph, source, weight, pred=nil, paths=nil, cutoff=nil, target=nil)
    help_multisource_dijkstra(graph, [source], weight, pred, paths, cutoff, target)
  end

  # Computes shortest paths and path lengths to a target from one of the nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param sources [Array<Object>] Array of sources
  # @param target [Object, nil] target node for the dijkstra algorithm
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [Numeric, Array<Object>] path lengths for all nodes
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

  # Computes shortest path lengths to any from the given nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param sources [Array<Object>] Array of sources
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [Hash{ Object => Numeric }] path lengths for any nodes from given nodes
  def self.multisource_dijkstra_path_length(graph, sources, cutoff=nil)
    raise ValueError, 'Sources cannot be empty' if sources.empty?

    weight = get_weight(graph)
    help_multisource_dijkstra(graph, sources, weight, nil, nil, cutoff)
  end

  # Computes shortest paths to any from the given nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param sources [Array<Object>] Array of sources
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [Hash{ Object => Array<Object> }] paths for any nodes from given nodes
  def self.multisource_dijkstra_path(graph, sources, cutoff=nil)
    _, path = multisource_dijkstra(graph, sources, nil, cutoff)
    path
  end

  # Computes shortest paths and path distances to all nodes/target from the given node
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param target [Object] target
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [Hash{ Object => Array<Object> }, Array<Object>] paths for all nodes/target node from given node
  def self.singlesource_dijkstra(graph, source, target=nil, cutoff=nil)
    multisource_dijkstra(graph, [source], target, cutoff)
  end

  # Computes shortest path lengths to all nodes from the given node
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [Hash{ Object => Numeric }] path lengths for all nodes from given node
  def self.singlesource_dijkstra_path_length(graph, source, cutoff=nil)
    multisource_dijkstra_path_length(graph, [source], cutoff)
  end

  # Computes shortest paths to all nodes from the given node
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [Hash{ Object => Array<Object> }] paths for all nodes from given node
  def self.singlesource_dijkstra_path(graph, source, cutoff=nil)
    multisource_dijkstra_path(graph, [source], cutoff)
  end

  # Computes shortest path length to target from the given node
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param target [Object] target
  #
  # @return [Numeric] path length for target node from given node
  def self.dijkstra_path_length(graph, source, target)
    return 0 if source == target

    weight = get_weight(graph)
    length = help_dijkstra(graph, source, weight, nil, nil, nil, target)
    raise KeyError, 'Node not reachable!' unless length.key?(target)

    length[target]
  end

  # Computes shortest path to target from the given node
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param target [Object] target
  #
  # @return [Numeric] path for target node from given node
  def self.dijkstra_path(graph, source, target)
    _, path = singlesource_dijkstra(graph, source, target)
    path
  end

  # Computes weighted shortest path length and predecessors
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [<Array<Hash{ Object => Array<Object> }, Hash{ Object => Numeric }>]
  #         predcessor hash and distance hash
  def self.dijkstra_predecessor_distance(graph, source, cutoff=nil)
    weight = get_weight(graph)
    pred = {source => []}
    [pred, help_dijkstra(graph, source, weight, pred, nil, cutoff)]
  end

  # Finds shortest weighted paths and lengths between all nodes
  #
  # @param graph [Graph, DiGrhelp_dijkaph, MultiGraph, MultiDiGraph] a graph
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [Array<Object, Array<Hash{ Object => Numeric }, Hash{ Object => Array<Object> }>>]
  #          paths and path lengths between all nodes
  def self.all_pairs_dijkstra(graph, cutoff=nil)
    path = []
    graph.nodes.each_key { |n| path << [n, singlesource_dijkstra(graph, n, nil, cutoff)] }
    path
  end

  # Finds shortest weighted path length between all nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [Array<Object, Hash{ Object => Numeric }>] path lengths between all nodes
  def self.all_pairs_dijkstra_path_length(graph, cutoff=nil)
    path_lengths = []
    graph.nodes.each_key { |n| path_lengths << [n, singlesource_dijkstra_path_length(graph, n, cutoff)] }
    path_lengths
  end

  # Finds shortest weighted paths between all nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [Array<Object, Hash{ Object => Array<Object> }>] path lengths between all nodes
  def self.all_pairs_dijkstra_path(graph, cutoff=nil)
    paths = []
    graph.nodes.each_key { |n| paths << singlesource_dijkstra_path(graph, n, cutoff) }
    paths
  end

  # TODO: Reduce method length and method complexity

  # Helper function for bellman ford
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

  # Finds shortest weighted path lengths and predecessors on shortest paths
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param target [Object, nil] target
  # @param cutoff [Numeric, nil] cutoff for the dijkstra algorithm
  #
  # @return [Array<Hash{ Object => Array<Object> }, Hash{ Object => Numeric }>] predecessors and distances
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

  # Length of shortest path from source to target using Bellman Ford algorithm
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param target [Object] target
  #
  # @return [Numeric] distance between source and target
  def self.bellmanford_path_length(graph, source, target)
    return 0 if source == target

    weight = get_weight(graph)
    length = help_bellman_ford(graph, [source], weight, nil, nil, nil, nil, target)
    raise ArgumentError, 'Node not reachable!' unless length.key?(target)

    length[target]
  end

  # Shortest path from source to target using Bellman Ford algorithm
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param target [Object] target
  #
  # @return [Array<Object>] path from source to target
  def self.bellmanford_path(graph, source, target)
    _, path = singlesource_bellmanford(graph, source, target)
    path
  end

  # Shortest path from source to all nodes using Bellman Ford algorithm
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param cutoff [Numeric, nil] cutoff for Bellman Ford algorithm
  #
  # @return [Hash{ Object => Array<Object> }] path from source to all nodes
  def self.singlesource_bellmanford_path(graph, source, cutoff=nil)
    _, path = singlesource_bellmanford(graph, source, cutoff)
    path
  end

  # Shortest path length from source to all nodes using Bellman Ford algorithm
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source
  # @param cutoff [Numeric, nil] cutoff for Bellman Ford algorithm
  #
  # @return [Hash{ Object => Numeric }] path lengths from source to all nodes
  def self.singlesource_bellmanford_path_length(graph, source, cutoff=nil)
    weight = get_weight(graph)
    help_bellman_ford(graph, [source], weight, nil, nil, nil, cutoff)
  end

  # Shortest path lengths between all nodes using Bellman Ford algorithm
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param cutoff [Numeric, nil] cutoff for Bellman Ford algorithm
  #
  # @return [Array<Object, Hash{ Object => Numeric }>] path lengths from source to all nodes
  def self.allpairs_bellmanford_path_length(graph, cutoff=nil)
    path_lengths = []
    graph.nodes.each_key { |n| path_lengths << [n, singlesource_bellmanford_path_length(graph, n, cutoff)] }
    path_lengths
  end

  # Shortest paths between all nodes using Bellman Ford algorithm
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param cutoff [Numeric, nil] cutoff for Bellman Ford algorithm
  #
  # @return [Array<Object, Hash{ Object => Array<Object> }>] path lengths from source to all nodes
  def self.allpairs_bellmanford_path(graph, cutoff=nil)
    paths = []
    graph.nodes.each_key { |n| paths << [n, singlesource_bellmanford_path(graph, n, cutoff)] }
    paths
  end

  # Helper function to get sources
  def self.get_sources(graph)
    graph.nodes.collect { |k, _v| k }
  end

  # Helper function to get distances
  def self.dist_path_lambda(_graph, _new_weight)
    lambda do |graph, v, new_weight|
      paths = {v => [v]}
      _ = help_dijkstra(graph, v, new_weight, nil, paths)
      paths
    end
  end

  # Helper function to set path lengths for Johnson algorithm
  def self.set_path_lengths_johnson(graph, dist_path, new_weight)
    path_lengths = []
    graph.nodes.each_key { |n| path_lengths << [n, dist_path.call(graph, n, new_weight)] }
    path_lengths
  end

  # TODO: Reduce method length and method complexity

  # Returns shortest path between all pairs of nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  #
  # @return [Array<Object, Hash { Object => Array<Object> }] shortest paths between all pairs of nodes
  def self.johnson(graph)
    dist, pred = {}, {}
    sources = get_sources(graph)
    graph.nodes.each_key do |n|
      dist[n], pred[n] = 0, []
    end
    weight = get_weight(graph)
    dist_bellman = help_bellman_ford(graph, sources, weight, pred, nil, dist)
    new_weight = ->(u, v, d) { weight.call(u, v, d) + dist_bellman[u] - dist_bellman[v] }
    dist_path = dist_path_lambda(graph, new_weight)
    set_path_lengths_johnson(graph, dist_path, new_weight)
  end
end
