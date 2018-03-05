module NetworkX
  class Graph
    attr_reader :adj, :nodes, :graph

    def initialize(**graph_attrs)
      @nodes = {}
      @adj = {}
      @graph = {}

      @graph = graph_attrs
    end

    def add_edge(node_1, node_2, **edge_attrs)
      add_node(node_1)
      add_node(node_2)

      edge_attrs = (@adj[node_1][node_2] || {}).merge(edge_attrs)
      @adj[node_1][node_2] = edge_attrs
      @adj[node_2][node_1] = edge_attrs
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
      if @nodes.key?(node)
        @nodes[node].merge!(node_attrs)
      else
        @adj[node] = {}
        @nodes[node] = node_attrs
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
      if @nodes.key?(node)
        @adj[node].each_key { |k| @adj[k].delete(node) }
        @adj.delete(node)
        @nodes.delete(node)
      else
        raise KeyError, "Error in deleting node #{node} from Graph."
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
