module NetworkX
  # TODO: Reduce method complexity and method length

  # Returns path using astar algorithm between source and target
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] a node to start astar from
  # @param target [Object] a node to end astar
  # @param heuristic [] a lambda to compute heuristic b/w two nodes
  #
  # @return [Array<Object>] an array of nodes forming a path between source
  #                         and target
  def self.astar_path(graph, source, target, heuristic=nil)
    warn 'A* is not implemented for MultiGraph and MultiDiGraph'
    raise ArgumentError, 'Either source or target is not in graph' unless graph.node?(source) && graph.node?(target)

    count = ->(i) { i + 1 }
    i = -1
    heuristic ||= (->(_u, _v) { 0 })
    heap = Heap.new { |x, y| x[0] < y[0] || (x[0] == y[0] && x[1] < y[1]) }
    heap << [0, count.call(i), source, 0, nil]
    enqueued, explored = {}, {}

    until heap.empty?
      _, _, curnode, dist, parent = heap.pop
      if curnode == target
        path = [curnode]
        node = parent
        until node.nil?
          path << node
          node = explored[node]
        end
        path.reverse
        return path
      end

      next if explored.key?(curnode)

      explored[curnode] = parent

      graph.adj[curnode].each do |u, attrs|
        next if explored.key?(u)

        ncost = dist + (attrs[:weight] || 1)
        if enqueued.key?(u)
          qcost, = enqueued[u]
          next if qcost <= ncost
        else
          h = heuristic.call(u, target)
          enqueued[u] = ncost, h
          heap << [ncost + h, count.call(i), u, ncost, curnode]
        end
      end
    end
    raise ArgumentError, 'Target not reachable!'
  end

  # Returns astar path length b/w source and target
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] a node to start astar from
  # @param target [Object] a node to end astar
  # @param heuristic [] a lambda to compute heuristic b/w two nodes
  #
  # @return [Numeric] the length of the path
  def self.astar_path_length(graph, source, target, heuristic=nil)
    raise ArgumentError, 'Either source or target is not in graph' unless graph.node?(source) && graph.node?(target)

    path = astar_path(graph, source, target, heuristic)
    path_length = 0
    (1..(path.length - 1)).each { |i| path_length += (graph.adj[path[i - 1]][path[i]][:weight] || 1) }
    path_length
  end
end
