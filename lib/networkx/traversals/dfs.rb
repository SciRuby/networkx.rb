module NetworkX
  # Returns edges of the graph travelled in depth first fashion
  #
  # @example
  #   NetworkX.dfs_edges(graph, source)
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start dfs from
  # @param depth_limit [Integer, nil] the depth limit of dfs
  def self.dfs_edges(graph, source, depth_limit = nil)
    raise KeyError, "There exists no node names #{source} in the given graph." unless graph.node?(source)

    depth_limit += 1 if depth_limit
    depth_limit = graph.nodes(data: true).length if depth_limit.nil?
    dfs_edges = []
    visited = [source]
    stack = [[-1, source, depth_limit, graph.neighbours(source)]]
    until stack.empty?
      earlier_node, parent, depth_now, children = stack.pop
      dfs_edges << [earlier_node, parent]
      children.each_key do |child|
        unless visited.include?(child)
          visited << child
          stack.push([parent, child, depth_now - 1, graph.neighbours(child)]) if depth_now > 1
        end
      end
    end
    dfs_edges.shift
    dfs_edges
  end

  # Returns dfs tree of the graph
  #
  # @example
  #   NetworkX.dfs_tree(graph, source)
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start dfs from
  # @param depth_limit [Integer, nil] the depth limit of dfs
  def self.dfs_tree(graph, source, depth_limit = nil)
    t = NetworkX::DiGraph.new
    t.add_node(source)
    t.add_edges_from(dfs_edges(graph, source, depth_limit))
    t
  end

  # Returns parent successor pair of the graph travelled in depth first fashion
  #
  # @example
  #   NetworkX.dfs_successors(graph, source)
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start dfs from
  # @param depth_limit [Integer, nil] the depth limit of dfs
  def self.dfs_successors(graph, source, depth_limit = nil)
    dfs_edges = dfs_edges(graph, source, depth_limit)
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
  #   NetworkX.dfs_predecessors(graph, source)
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param source [Object] node to start dfs from
  # @param depth_limit [Integer, nil] the depth limit of dfs
  def self.dfs_predecessors(graph, source, depth_limit = nil)
    dfs_edges = dfs_edges(graph, source, depth_limit)
    predecessors = {}
    dfs_edges.each { |u, v| predecessors[v] = u }
    predecessors
  end

  class Graph
    # [EXPERIMENTAL]
    #
    # @param root [Object] node which is root, start, source
    #
    # @return [Array[Object]] nodes
    def dfs_preorder_nodes(root)
      each_dfs_preorder_node(root).to_a
    end

    # [EXPERIMENTAL]
    #
    # @param root [Object] node which is root, start, source
    def each_dfs_preorder_node(root)
      return enum_for(:each_dfs_preorder_node, root) unless block_given?

      st = [root]
      used = {root => true}
      while st[-1]
        node = st.pop
        yield(node)
        @adj[node].reverse_each do |v, _data|
          next if used[v]

          used[v] = node
          st << v
        end
      end
    end

    # [EXPERIMENTAL]
    #
    # @param root [Object] node which is root, start, source
    #
    # @return [Array[Object]] array of dfs postorder nodes
    def dfs_postorder_nodes(root, used = {root => true})
      res = []
      @adj[root].each do |v, _data|
        next if used[v]

        used[v] = true
        res.concat dfs_postorder_nodes(v, used)
      end

      res << root
      res
    end

    # @param root [Object] node which is root, start, source
    def each_dfs_postorder_node(root, &block)
      return enum_for(:each_dfs_postorder_node, root) unless block_given?

      dfs_postorder_nodes(root).each(&block)
    end
  end
end
