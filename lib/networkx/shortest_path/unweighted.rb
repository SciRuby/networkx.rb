module NetworkX
  # Helper function for single source shortest path length
  def self.help_single_shortest_path_length(adj, firstlevel, cutoff)
    Enumerator.new do |e|
      seen = {}
      level = 0
      nextlevel = firstlevel

      while !nextlevel.empty? && cutoff >= level
        thislevel = nextlevel
        nextlevel = {}
        thislevel.each do |u, _attrs|
          next if seen.key?(u)

          seen[u] = level
          nextlevel.merge!(adj[u])
          e.yield [u, level]
        end
        level += 1
      end
      seen.clear
    end
  end

  # Computes shortest path values to all nodes from a given node
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source to compute path length from
  # @param cutoff [Numeric, nil] cutoff for the shortest path algorithm
  #
  # @return [Array<Object, Numeric>] path lengths for all nodes
  def self.single_source_shortest_path_length(graph, source, cutoff=nil)
    raise ArgumentError, 'Source not found in the Graph!' unless graph.node?(source)

    cutoff = Float::INFINITY if cutoff.nil?
    nextlevel = {source => 1}
    help_single_shortest_path_length(graph.adj, nextlevel, cutoff).take(graph.nodes.length)
  end

  # Computes shortest path values to all nodes from all nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param cutoff [Numeric, nil] cutoff for the shortest path algorithm
  #
  # @return [Array<Object, Array<Object, Numeric>>] path lengths for all nodes from all nodes
  def self.all_pairs_shortest_path_length(graph, cutoff=nil)
    shortest_paths = []
    graph.nodes.each_key { |n| shortest_paths << [n, single_source_shortest_path_length(graph, n, cutoff)] }
    shortest_paths
  end

  # Helper function for finding single source shortest path
  def self.help_single_shortest_path(adj, firstlevel, paths, cutoff)
    level = 0
    nextlevel = firstlevel
    while !nextlevel.empty? && cutoff > level
      thislevel = nextlevel
      nextlevel = {}
      thislevel.each_key do |u|
        adj[u].each_key do |v|
          unless paths.key?(v)
            paths[v] = paths[u] + [v]
            nextlevel[v] = 1
          end
        end
      end
      level += 1
    end
    paths
  end

  # Computes single source shortest path from a node to every other node
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source from which shortest paths are needed
  # @param cutoff [Numeric, nil] cutoff for the shortest path algorithm
  #
  # @return [Array<Object, Array<Object, Array<Object>>>] path lengths for all nodes from all nodes
  def self.single_source_shortest_path(graph, source, cutoff=nil)
    raise ArgumentError, 'Source not found in the Graph!' unless graph.node?(source)

    cutoff = Float::INFINITY if cutoff.nil?
    nextlevel = {source => 1}
    paths = {source => [source]}
    help_single_shortest_path(graph.adj, nextlevel, paths, cutoff)
  end

  # Computes shortest paths to all nodes from all nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param cutoff [Numeric, nil] cutoff for the shortest path algorithm
  #
  # @return [Array<Object, Hash {Object => Array<Object> }>] paths for all nodes from all nodes
  def self.all_pairs_shortest_path(graph, cutoff=nil)
    shortest_paths = []
    graph.nodes.each_key { |n| shortest_paths << [n, single_source_shortest_path(graph, n, cutoff)] }
    shortest_paths
  end

  # Computes shortest paths to all nodes from all nodes
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] source for which predecessors are needed
  # @param cutoff [Numeric, nil] cutoff for finding predecessor
  # @param return_seen [Boolean] if true, returns seen dict
  #
  # @return [Array<Hash{ Object => Array<Object> }, Hash{ Object => Numeric }>,
  #         Hash{ Object => Array<Object> }]
  #         predecessors of a given node and/or seen dict
  def self.predecessor(graph, source, cutoff=nil, return_seen=false)
    raise ArgumentError, 'Source not found in the Graph!' unless graph.node?(source)

    level = 0
    nextlevel = [source]
    seen = {source => level}
    pred = {source => []}
    until nextlevel.empty?
      level += 1
      thislevel = nextlevel
      nextlevel = []
      thislevel.each do |u|
        graph.adj[u].each_key do |v|
          if !seen.key?(v)
            pred[v] = [u]
            seen[v] = level
            nextlevel << v
          elsif seen[v] == level
            pred[v] << u
          end
        end
      end
      break if cutoff.nil? && cutoff <= level
    end
    return_seen ? [pred, seen] : pred
  end
end
