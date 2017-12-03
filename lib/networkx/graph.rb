module NetworkX
  class Graph
    def initialize
      @adj = Hash.new
    end

    def add_node(node)
      unless @adj.has_key? node
        @adj[node] = Hash.new
      end
    end

    def add_nodes_from(nodes)
      nodes.each {|node| add_node(node)}
    end

    def add_edge(node1, node2, **attrs)
      add_node(node1)
      add_node(node2)

      @adj[node1][node2] = attrs
    end

    def add_edges_from(edges)
      edges.each {|edge| add_edge(*edge)}
    end

  end
end