module NetworkX
  # Describes the class for making MultiGraphs
  #
  # @attr_reader adj [Hash{ Object => Hash{ Object => Hash{ Integer => Hash{ Object => Object } } } }]
  #                  Stores the edges and their attributes in an adjencency list form
  # @attr_reader nodes [Hash{ Object => Hash{ Object => Object } }] Stores the nodes and their attributes
  # @attr_reader graph [Hash{ Object => Object }] Stores the attributes of the gra
  class MultiGraph < Graph
    # Returns a new key
    #
    # @param node1 [Object] the first node of a given edge
    # @param node2 [Object] the second node of a given edge
    def new_edge_key(node1, node2)
      return 0 if @adj[node1][node2].nil?

      key = @adj[node1][node2].length
      key += 1 while @adj[node1][node2].has_key?(key)
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
    # @param node1 [Object] the first node of the edge
    # @param node2 [Object] the second node of the edge
    # @param edge_attrs [Hash{ Object => Object }] the hash of the edge attributes
    def add_edge(node1, node2, **edge_attrs)
      add_node(node1)
      add_node(node2)
      key = new_edge_key(node1, node2)
      all_edge_attrs = @adj[node1][node2] || {}
      all_edge_attrs[key] = edge_attrs
      @adj[node1][node2] = all_edge_attrs
      @adj[node2][node1] = all_edge_attrs
    end

    # Removes edge from the graph
    #
    # @example
    #   graph.remove_edge('Noida', 'Bangalore')
    #
    # @param node1 [Object] the first node of the edge
    # @param node2 [Object] the second node of the edge
    def remove_edge(node1, node2, key = nil)
      return super(node1, node2) if key.nil?

      raise KeyError, "#{node1} is not a valid node." unless @nodes.has_key?(node1)
      raise KeyError, "#{node2} is not a valid node" unless @nodes.has_key?(node2)
      raise KeyError, 'The given edge is not a valid one.' unless @adj[node1].has_key?(node2)

      if @adj[node1][node2].none? { |_index, data| data[:key] == key }
        raise KeyError, 'The given edge is not a valid one'
      end

      @adj[node1][node2].delete_if { |_indx, data| data[:key] == key }
      @adj[node2][node1].delete_if { |_indx, data| data[:key] == key }
    end

    # Returns the size of the graph
    #
    # @example
    #   graph.size(true)
    #
    # @param is_weighted [Bool] if true, method returns sum of weights of all edges
    #                           else returns number of edges
    def size(is_weighted = false)
      if is_weighted
        graph_size = 0
        @adj.each do |_, hash_val|
          hash_val.each { |_, v| v.each { |_, attrs| graph_size += attrs[:weight] if attrs.has_key?(:weight) } }
        end
        return graph_size / 2
      end
      number_of_edges
    end

    # Returns number of edges
    #
    # @example
    #   graph.number_of_edges
    def number_of_edges
      @adj.values.flat_map(&:values).map(&:length).sum / 2
    end

    # Checks if the the edge consisting of two nodes is present in the graph
    #
    # @example
    #   graph.edge?(node1, node2)
    #
    # @param node1 [Object] the first node of the edge to be checked
    # @param node2 [Object] the second node of the edge to be checked
    # @param key [Integer] the key of the given edge
    def edge?(node1, node2, key = nil)
      return super(node1, node2) if key.nil?

      node?(node1) && @adj[node1].has_key?(node2) && @adj[node1][node2].has_key?(key)
    end

    def has_edge?(node1, node2, key = nil)
      return super(node1, node2) if key.nil?

      return false unless node?(node1) && @adj[node1].has_key?(node2)

      @adj[node1][node2].any? { |_index, data| data[:key] == key }
    end

    def each_edge(data: false)
      return enum_for(:each_edge, data: data) unless block_given?

      @adj.each do |v, ws|
        ws.each do |w, key_and_info|
          next if v > w

          key_and_info.each do |key, info|
            data ? yield(v, w, key, info) : yield(v, w, key)
          end
        end
      end
    end

    # Returns the undirected version of the graph
    #
    # @example
    #   graph.to_undirected
    def to_undirected
      graph = NetworkX::Graph.new(**@graph)
      @nodes.each { |node, node_attr| graph.add_node(node, **node_attr) }
      @adj.each do |node1, node1_edges|
        node1_edges.each do |node2, node1_node2|
          edge_attrs = {}
          node1_node2.each { |_key, attrs| edge_attrs.merge!(attrs) }
          graph.add_edge(node1, node2, **edge_attrs)
        end
      end
      graph
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
        sub_graph = NetworkX::MultiGraph.new(**@graph)
        nodes.each do |u, _|
          raise KeyError, "#{u} does not exist in the current graph!" unless @nodes.has_key?(u)

          sub_graph.add_node(u, **@nodes[u])
          @adj[u].each do |v, edge_val|
            next if u > v

            edge_val.each { |_, keyval| sub_graph.add_edge(u, v, **keyval) if @adj[u].has_key?(v) && nodes.include?(v) }
          end
        end
        sub_graph
      else
        raise ArgumentError, 'Expected Argument to be Array or Set of nodes, ' \
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
        sub_graph = NetworkX::MultiGraph.new(**@graph)
        edges.each do |u, v|
          raise KeyError, "Edge between #{u} and #{v} does not exist in the graph!" unless @nodes.has_key?(u) \
                                                                                    && @adj[u].has_key?(v)

          sub_graph.add_node(u, **@nodes[u])
          sub_graph.add_node(v, **@nodes[v])
          @adj[u][v].each { |_, keyval| sub_graph.add_edge(u, v, **keyval) }
        end
        sub_graph
      else
        raise ArgumentError, 'Expected Argument to be Array or Set of edges, ' \
                             "received #{edges.class.name} instead."
      end
    end
  end
end
