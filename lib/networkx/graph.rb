module NetworkX
  class Graph
    def initialize
      @adj = {}
    end

    def add_node(node)
      @adj[node] = {} unless @adj.key? node
    end

    def add_nodes_from(nodes)
      nodes.each { |node| add_node(node) }
    end

    def add_edge(node_1, node_2, **attrs)
      add_node(node_1)
      add_node(node_2)

      @adj[node_1][node_2] = attrs
    end

    def add_edges_from(edges)
      edges.each { |edge| add_edge(*edge) }
    end

    def remove_node(node)
      @adj.delete(node)
      @adj.each_key { |key| @adj[key].delete(node) }
    end

    def remove_nodes_from(nodes)
      nodes.each { |node| @adj.delete(node) }
      nodes.each { |node| @adj.each_key { |key| @adj[key].delete(node) } }
    end

    def remove_edge(node_1, node_2)
      @adj[node_1].delete(node_2) if @adj.key? node_1
    end

    def remove_edges_from(edges)
      edges.each { |edge| remove_edge(*edge) }
    end
  end
end
