module NetworkX
  # TODO: Reduce method length

  # Returns edges of the graph travelled in breadth first fashion
  #
  # @example
  #   NetworkX.bfs_edges(graph, source)
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start bfs from
  def self.bfs_edges(graph, source)
    raise KeyError, "There exists no node names #{source} in the given graph." unless graph.node?(source)

    bfs_edges = []
    visited = [source]
    queue = Queue.new.push([source, graph.neighbours(source)])
    until queue.empty?
      parent, children = queue.pop
      children.each_key do |child|
        next if visited.include?(child)

        bfs_edges << [parent, child]
        visited << child
        queue.push([child, graph.neighbours(child)])
      end
    end
    bfs_edges
  end

  # Returns parent successor pair of the graph travelled in breadth first fashion
  #
  # @example
  #   NetworkX.bfs_successors(graph, source)
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start bfs from
  def self.bfs_successors(graph, source)
    bfs_edges = bfs_edges(graph, source)
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
  #   NetworkX.bfs_predecessors(graph, source)
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start bfs from
  def self.bfs_predecessors(graph, source)
    bfs_edges = bfs_edges(graph, source)
    predecessors = {}
    bfs_edges.each { |u, v| predecessors[v] = u }
    predecessors
  end
end
