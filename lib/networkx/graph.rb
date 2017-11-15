module NetworkX
  class Graph
    def initialize
      @nodes = Set.new
      @edges = {}
    end

    def add_edge(node_1, node_2, **attrs)
      add_node(node_1)
      add_node(node_2)

      edge_key         = Set.new([node_1, node_2])
      @edges[edge_key] = attrs
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

    def add_node(node)
      @nodes.add(node)
    end

    def add_nodes(nodes)
      case nodes
      when Set, Array
        nodes.each { |node| add_node(node) }
      else
        raise ArgumentError, 'Expected argument to be an Array or Set of nodes, '\
                             "received #{nodes.class.name} instead."
      end
    end
  end
end
