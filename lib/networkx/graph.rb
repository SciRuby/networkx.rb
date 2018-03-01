module NetworkX
  class Graph
    attr_reader :_adj, :_nodes

    def initialize(**graph_attrs)
      @_nodes = {}
      @_adj = {}
      @graph = {}

      @graph.merge!(graph_attrs)
    end

    def add_edge(node_1, node_2, **edge_attrs)
      add_node(node_1)
      add_node(node_2)

      attrs_hash = @_adj[node_1][node_2]
      attrs_hash = {} if attrs_hash == nil
      attrs_hash.merge!(edge_attrs)
      @_adj[node_1][node_2] = attrs_hash
      @_adj[node_2][node_1] = attrs_hash
    end

    def add_edges(edges)
      case edges
      when Array
        edges.each { |node_1, node_2, **attrs| add_edge(node_1, node_2, **attrs) }
      else
        raise ArgumentError, 'Expected argument to be an Array of edges, '\
                             "received #{edges.class.name} instead."
      end
    end

    def add_node(node, **node_attrs)
      if !@_nodes.key?(node)
        @_adj[node] = {}
        @_nodes[node] = node_attrs
      else
        @_nodes[node].merge!(node_attrs)
      end
    end

    def add_nodes(nodes)
      case nodes
      when Set, Array
        nodes.each { |node, **node_attrs| add_node(node, node_attrs) }
      else
        raise ArgumentError, 'Expected argument to be an Array or Set of nodes, '\
                             "received #{nodes.class.name} instead."
      end
    end

    def remove_node(node)
      begin
        @_adj[node].each { |k, v| @_adj[k].delete(node) }
        @_adj.delete(node)
        @_nodes.delete(node)
      rescue
        raise KeyError, "Error in deleting node #{node.to_s} from Graph."
      end
    end

    def remove_nodes(nodes)
      case nodes
      when Set, Array
        nodes.each { |node| remove_node(node) }
      else
        raise ArgumentError, 'Expected argument to be an Array or Set of nodes, '\
                             "received #{nodes.class.name} instead."
      end
    end

  end
end
