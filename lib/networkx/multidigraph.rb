module NetworkX
  class MultiDiGraph < DiGraph
    # Returns a new key
    #
    # @param node_1 [Object] the first node of a given edge
    # @param node_2 [Object] the second node of a given edge
    def new_edge_key(node_1, node_2)
      return 0 if @adj[node_1][node_2].nil?
      key = @adj[node_1][node_2].length
      key += 1 while @adj[node_1][node_2].key?(key)
      key
    end

    # Adds the respective edge
    #
    # @example Add an edge with attribute name
    #   graph.add_edge(node1, node2, name: "Edge1")
    #
    # @example Add an edge with no attribute
    #   graph.add_edge("Bangalore", "Chennai")
    #
    # @param node_1 [Object] the first node of the edge
    # @param node_2 [Object] the second node of the edge
    # @param edge_attrs [Hash{ Object => Object }] the hash of the edge attributes
    def add_edge(node_1, node_2, **edge_attrs)
      add_node(node_1)
      add_node(node_2)
      key = new_edge_key(node_1, node_2)
      all_edge_attrs = @adj[node_1][node_2] || {}
      all_edge_attrs[key] = edge_attrs
      @adj[node_1][node_2] = all_edge_attrs
      @pred[node_2][node_1] = all_edge_attrs
    end

    # Removes edge from the graph
    #
    # @example
    #   graph.remove_edge('Noida', 'Bangalore')
    #
    # @param node_1 [Object] the first node of the edge
    # @param node_2 [Object] the second node of the edge
    def remove_edge(node_1, node_2, key=nil)
      if key.nil?
        super(node_1, node_2)
        return
      end
      raise KeyError, "#{node_1} is not a valid node." unless @nodes.key?(node_1)
      raise KeyError, "#{node_2} is not a valid node" unless @nodes.key?(node_2)
      raise KeyError, 'The given edge is not a valid one.' unless @adj[node_1].key?(node_2)
      raise KeyError, 'The given edge is not a valid one.' unless @adj[node_1][node_2].key?(key)
      @adj[node_1][node_2].delete(key)
      @pred[node_2][node_1].delete(key)
    end

    # Checks if the the edge consisting of two nodes is present in the graph
    #
    # @example
    #   graph.edge?(node_1, node_2)
    #
    # @param node_1 [Object] the first node of the edge to be checked
    # @param node_2 [Object] the second node of the edge to be checked
    # @param key [Integer] the key of the given edge
    def edge?(node_1, node_2, key=nil)
      super(node_1, node_2) if key.nil?
      return true if @nodes.key?(node_1) && @adj[node_1].key?(node_2) && @adj[node_1][node_2].key?(key)
      false
    end

    # Returns the undirected version of the graph
    #
    # @example
    #   graph.to_undirected
    def to_undirected
      graph = NetworkX::Graph.new(@graph)
      @nodes.each { |node, node_attr| graph.add_node(node, node_attr) }
      @adj.each_key do |node_1|
        @adj[node_1].each_key do |node_2|
          edge_attrs = {}
          @adj[node_1][node_2].each_key { |key| edge_attrs.merge!(@adj[node_1][node_2][key]) }
          graph.add_edge(node_1, node_2, edge_attrs)
        end
      end
      graph
    end

    # Returns the directed version of the graph
    #
    # @example
    #   graph.to_directed
    def to_directed
      graph = NetworkX::DiGraph.new(@graph)
      @nodes.each { |node, node_attr| graph.add_node(node, node_attr) }
      @adj.each_key do |node_1|
        @adj[node_1].each_key do |node_2|
          edge_attrs = {}
          @adj[node_1][node_2].each_key { |key| edge_attrs.merge!(@adj[node_1][node_2][key]) }
          graph.add_edge(node_1, node_2, edge_attrs)
        end
      end
      graph
    end

    # Returns the multigraph version of the graph
    #
    # @example
    #   graph.to_multigraph
    def to_multigraph
      graph = NetworkX::MultiGraph.new(@graph)
      @nodes.each { |node, node_attr| graph.add_node(node, node_attr) }
      @adj.each_key do |node_1|
        @adj[node_1].each_key do |node_2|
          edge_attrs = {}
          @adj[node_1][node_2].each_key { |key| graph.add_edge(node_1, node_2, @adj[node_1][node_2][key]) }
          graph.add_edge(node_1, node_2, edge_attrs)
        end
      end
      graph
    end

    # Returns the reversed version of a the graph
    #
    # @example
    #   graph.reverse
    def reverse
      new_graph = NetworkX::MultiDiGraph.new(@graph)
      @nodes.each_key { |k| new_graph.add_node(k, @nodes[k]) }
      @adj.each_key do |u|
        @adj[u].each_key { |v| @adj[u][v].each_key { |k| new_graph.add_edge(v, u, @adj[u][v][k]) } }
      end
      new_graph
    end

    # Returns in-degree of a given node
    #
    # @example
    #   graph.in_degree(node)
    #
    # @param node [Object] the node whose in degree is to be calculated
    def in_degree(node)
      in_degree_no = 0
      @pred[node].each_key { |u| in_degree_no += @pred[node][u].length }
      in_degree_no
    end

    # Returns out-degree of a given node
    #
    # @example
    #   graph.out_degree(node)
    #
    # @param node [Object] the node whose out degree is to be calculated
    def out_degree(node)
      out_degree_no = 0
      @adj[node].each_key { |u| out_degree_no += @adj[node][u].length }
      out_degree_no
    end

    # Returns number of edges
    #
    # @example
    #   graph.number_of_edges
    def number_of_edges
      no_of_edges = 0
      @adj.each_key { |node_1| @adj[node_1].each_key { |node_2| no_of_edges += @adj[node_1][node_2].length } }
      no_of_edges
    end

    # Returns number of edges if is_weighted is false
    # or returns total weight of all edges
    #
    # @example
    #   graph.size(true)
    #
    # @praram is_weighted [Bool] if we want weighted size of unweighted size
    def size(is_weighted=false)
      if is_weighted
        graph_size = 0
        @adj.each do |_, hash_val|
          hash_val.each { |_, v| v.each { |_, attrs| graph_size += attrs[:weight] if attrs.key?(:weight) } }
        end
        return graph_size
      end
      number_of_edges
    end

    # Returns subgraph consisting of given array of nodes
    #
    # @example
    #   graph.subgraph(%w[Mumbai Nagpur])
    #
    # @param nodes [Array<Object>] the nodes to be included in the subgraph
    def subgraph(nodes)
      case nodes
      when Array, Set
        sub_graph = NetworkX::MultiDiGraph.new(@graph)
        nodes.each do |u, _|
          raise KeyError, "#{u} does not exist in the current graph!" unless @nodes.key?(u)
          sub_graph.add_node(u, @nodes[u])
          @adj[u].each do |v, edge_val|
            edge_val.each { |_, keyval| sub_graph.add_edge(u, v, keyval) if @adj[u].key?(v) && nodes.include?(v) }
          end
          return sub_graph
        end
      else
        raise ArgumentError, 'Expected Argument to be Array or Set of nodes, '\
                             "received #{nodes.class.name} instead."
      end
    end

    # Returns subgraph conisting of given edges
    #
    # @example
    #   graph.edge_subgraph([%w[Nagpur Wardha], %w[Nagpur Mumbai]])
    #
    # @param edges [Array<Object, Object>] the edges to be included in the subraph
    def edge_subgraph(edges)
      case edges
      when Array, Set
        sub_graph = NetworkX::MultiDiGraph.new(@graph)
        edges.each do |u, v|
          raise KeyError, "Edge between #{u} and #{v} does not exist in the graph!" unless @nodes.key?(u)\
                                                                                    && @adj[u].key?(v)
          sub_graph.add_node(u, @nodes[u])
          sub_graph.add_node(v, @nodes[v])
          @adj[u][v].each { |_, keyval| sub_graph.add_edge(u, v, keyval) }
        end
        return sub_graph
      else
        raise ArgumentError, 'Expected Argument to be Array or Set of edges, '\
        "received #{edges.class.name} instead."
      end
    end
  end
end
