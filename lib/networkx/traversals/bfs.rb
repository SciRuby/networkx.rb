module NetworkX
  # Returns edges of the graph travelled in breadth first fashion
  #
  # @example
  #   NetworkX.bfs_edges(g, source)
  #
  # @param g [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start bfs from
  def self.bfs_edges(g, source)
    raise KeyError, "There exists no node names #{source} in the given graph." unless g.node?(source)
    bfs_edges = []
    visited = [source]
    queue = Queue.new.push([source, g.neighbours(source)])
    until queue.empty?
      parent, children = queue.pop
      children.each_key do |child|
        next if visited.include?(child)
        bfs_edges << [parent, child]
        visited << child
        queue.push([child, g.neighbours(child)])
      end
    end
    bfs_edges
  end

  # Returns parent successor pair of the graph travelled in breadth first fashion
  #
  # @example
  #   NetworkX.bfs_successors(g, source)
  #
  # @param g [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start bfs from
  def self.bfs_successors(g, source)
    bfs_edges = bfs_edges(g, source)
    parent = source
    successors = {}
    bfs_edges.each do |u, v|
      successors[u] = [] if successors[u].nil?
      successors[u] << v
    end
    successors
  end

  # Returns predecessor child pair of the graph travelled in breadth first fashion
  #
  # @example
  #   NetworkX.bfs_predecessors(g, source)
  #
  # @param g [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start bfs from
  def self.bfs_predecessors(g, source)
    bfs_edges = bfs_edges(g, source)
    predecessors = {}
    bfs_edges.each { |u, v| predecessors[v] = u }
    predecessors
  end
end
