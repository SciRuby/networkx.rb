module NetworkX
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

  class Graph
    def bfs_nodes(root)
      each_bfs_node(root).to_a
    end

    def each_bfs_node(root)
      return enum_for(:each_bfs_node, root) unless block_given?

      queue = [root]
      dist = {root => 0}
      while (v = queue.shift)
        yield v
        d = dist[v]
        @adj[v].each do |u, _data|
          next if dist[u]

          dist[u] = d + 1
          queue << u
        end
      end
    end

    # [EXPERIMENTAL]
    #
    # @param [Object] node which is root, start ,source
    def bfs_edges(node)
      each_bfs_edge(node).to_a
    end

    # [EXPERIMENTAL]
    #
    # @param [Object] node which is root, start ,source
    def each_bfs_edge(node)
      return enum_for(:each_bfs_edge, node) unless block_given?

      que = [node]
      used = {node => true}
      while que[0]
        node = que.shift

        @adj[node].each do |v, _data|
          next if used[v]

          used[v] = true

          yield(node, v)
          que << v
        end
      end
    end
  end
end
