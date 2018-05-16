module NetworkX
  class MultiGraph < Graph

    def new_edge_key(node_1, node_2)
      begin
        key_hash = @adj[node_1][node_2]
      rescue KeyError
          return 0
      end
      key = key_hash.length
      key + 1
    end

    def add_edge(node_1, node_2, **edge_attrs)
      add_node(node_1)
      add_node(node_2)
      key = new_edge_key(node_1, node_2)
      all_edge_attrs = @adj[node_1][node_2] || {}
      all_edge_attrs[key] = edge_attrs
      @adj[node_1][node_2] = all_edge_attrs
      @adj[node_2][node_1] = all_edge_attrs
    end

    def remove_edge(node_1, node_2, key=nil)
      raise KeyError, "#{node_1} is not a valid node." unless @nodes.key?(node_1)
      raise KeyError, "#{node_2} is not a valid node" unless @nodes.key?(node_2)
      raise KeyError, 'The given edge is not a valid one.' unless @adj[node_1].key?(node_2)
      raise KeyError, 'The given edge is not a valid one.', unless key != nil && @adj[node_1][node_2].key?(key)
      super(node_1, node_2) if key == nil
      @adj[node_1][node_2].delete(key)
      @adj[node_2][node_1].delete(key)
    end

    def has_edge(node_1, node_2, key=nil)
      super(node_1, node_2) if key == nil
      return true if @nodes.key?(node_1) and @adj[node_1].key?(node_2) && @adj[node_1][node_2].key?(key)
      false
    end

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
  end
end