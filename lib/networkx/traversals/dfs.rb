module NetworkX
  # Returns edges of the graph travelled in depth first fashion
  #
  # @example
  #   NetworkX.dfs_edges(g, source)
  #
  # @param g [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start dfs from
  # @param depth_limit [Integer, nil] the depth limit of dfs
  def self.dfs_edges(g, source, depth_limit=nil)
    raise KeyError, "There exists no node names #{source} in the given graph." unless g.node?(source)
    depth_limit = g.nodes.length if depth_limit.nil?
    dfs_edges = []
    visited = [source]
    stack = [[-1, source, depth_limit, g.neighbours(source)]]
    earlier_node = -1
    until stack.empty?
      earlier_node, parent, depth_now, children = stack.pop
      dfs_edges << [earlier_node, parent]
      children.each_key do |child|
        unless visited.include?(child)
          visited << child
          stack.push([parent, child, depth_now - 1, g.neighbours(child)]) if depth_now > 1
        end
      end
    end
    dfs_edges.shift
    dfs_edges
  end

  # Returns dfs tree of the graph
  #
  # @example
  #   NetworkX.dfs_tree(g, source)
  #
  # @param g [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start dfs from
  # @param depth_limit [Integer, nil] the depth limit of dfs
  def self.dfs_tree(g, source, depth_limit=nil)
    t = NetworkX::DiGraph.new
    t.add_node(source)
    t.add_edges_from(dfs_edges(g, source, depth_limit))
    t
  end

  # Returns parent successor pair of the graph travelled in depth first fashion
  #
  # @example
  #   NetworkX.dfs_successors(g, source)
  #
  # @param g [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start dfs from
  # @param depth_limit [Integer, nil] the depth limit of dfs
  def self.dfs_successors(g, source, depth_limit=nil)
    dfs_edges = dfs_edges(g, source, depth_limit)
    parent = source
    successors = {}
    dfs_edges.each do |u, v|
      successors[u] = [] if successors[u].nil?
      successors[u] << v
    end
    successors
  end

  # Returns predecessor child pair of the graph travelled in depth first fashion
  #
  # @example
  #   NetworkX.dfs_predecessors(g, source)
  #
  # @param g [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start dfs from
  # @param depth_limit [Integer, nil] the depth limit of dfs
  def self.dfs_predecessors(g, source, depth_limit=nil)
    dfs_edges = dfs_edges(g, source, depth_limit)
    predecessors = {}
    dfs_edges.each { |u, v| predecessors[v] = u }
    predecessors
  end
end
