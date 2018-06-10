require 'pry'
module NetworkX
  def self.help_single_shortest_path_length(adj, firstlevel, cutoff)
    e = Enumerator.new do |e|
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
    e
  end

  def self.single_source_shortest_path_length(g, source, cutoff=nil)
    raise ArgumentError, 'Source not found in the Graph!' unless g.node?(source)
    cutoff = Float::INFINITY if cutoff.nil?
    nextlevel = {source => 1}
    help_single_shortest_path_length(g.adj, nextlevel, cutoff).take(g.nodes.length)
  end

  def self.all_pairs_shortest_path_length(g, cutoff=nil)
    shortest_paths = []
    g.nodes.each_key { |n| shortest_paths << [n, single_source_shortest_path_length(g, n, cutoff)] }
    shortest_paths
  end

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

  def self.single_source_shortest_path(g, source, cutoff=nil)
    raise ArgumentError, 'Source not found in the Graph!' unless g.node?(source)
    cutoff = Float::INFINITY if cutoff.nil?
    nextlevel = {source => 1}
    paths = {source => [source]}
    help_single_shortest_path(g.adj, nextlevel, paths, cutoff)
  end

  def self.all_pairs_shortest_path(g, cutoff=nil)
    shortest_paths = []
    g.nodes.each_key { |n| shortest_paths << [n, single_source_shortest_path(g, n, cutoff)] }
    #   binding.pry
    shortest_paths
  end

  def self.predecessor(g, source, cutoff=nil, return_seen=nil)
    raise ArgumentError, 'Source not found in the Graph!' unless g.node?(source)
    level = 0
    nextlevel = [source]
    seen = {source => level}
    pred = {source => []}
    until nextlevel.empty?
      level += 1
      thislevel = nextlevel
      nextlevel = []
      thislevel.each do |u|
        g.adj[u].each_key do |v|
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
