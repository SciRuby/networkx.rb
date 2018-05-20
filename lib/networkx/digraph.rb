module NetworkX
  class DiGraph < Graph
    attr_reader :adj, :nodes, :graph, :pred
        
    def initialize(**graph_attrs)
      super(graph_attrs)

      @pred = {}
    end

    def add_edge(node_1, node_2, **edge_attrs)
      add_node(node_1)
      add_node(node_2)

      edge_attrs = (@adj[node_1][node_2] || {}).merge(edge_attrs)
      @adj[node_1][node_2] = edge_attrs
      @pred[node_2][node_1] = edge_attrs
    end

    def add_node(node, **node_attrs)
      super(node, node_attrs)

      if !@pred.key?(node)
        @pred[node] = {}
      end
    end

    def remove_node(node)
      raise KeyError, "Error in deleting node #{node} from Graph." unless @nodes.key?(node)
      
      neighbours = @adj[node]
      neighbours.each_key { |k| @pred[k].delete(node) }
      @pred[node].each_key do |k|  
        @adj[k].delete(node)
      end

      @pred.delete(node)
      @adj.delete(node)
      @nodes.delete(node)
    end

    def remove_edge(node_1, node_2)
      raise KeyError, "#{node_1} is not a valid node." unless @nodes.key?(node_1)
      raise KeyError, "#{node_2} is not a valid node" unless @nodes.key?(node_2)
      raise KeyError, 'The given edge is not a valid one.' unless @adj[node_1].key?(node_2)

      @adj[node_1].delete(node_2)
      @pred[node_2].delete(node_1)
    end

    def clear
      super
      
      @pred.clear
    end

    def number_of_edges
      num = 0
      @adj.each { |_, v| num += v.length }
      num
    end

    def size(is_weighted=false)
      if is_weighted
        graph_size = 0
        @adj.each do |_, hash_val|
          hash_val.each { |_, v| graph_size += v[:weight] if v.key?(:weight) }
        end
        return graph_size
      end
      number_of_edges
    end

    def in_degree(node)
      @pred[node].length
    end

    def out_degree(node)
      @adj[node].length
    end

    def reverse
      new_graph = NetworkX::DiGraph.new(@graph)
      @nodes.each_key { |k| new_graph.add_node(k, @nodes[k]) }
      @adj.each_key do |k|
        @adj[k].each_key { |v| new_graph.add_edge(v, k, @adj[k][v]) }
      end
      new_graph
    end

    def to_undirected
      new_graph = NetworkX::Graph.new(@graph)
      @nodes.each_key { |k| new_graph.add_node(k, @nodes[k]) }
      @adj.each_key do |k|
        @adj[k].each_key { |v| new_graph.add_edge(v, k, @adj[k][v]) }
      end
      new_graph 
    end
  
    def subgraph(nodes)
      case nodes
      when Array, Set
        sub_graph = NetworkX::DiGraph.new(@graph)
        nodes.each do |u, _|
          raise KeyError, "#{u} does not exist in the current graph!" unless @nodes.key?(u)
          sub_graph.add_node(u, @nodes[u])
          @adj[u].each do |v, edge_val|
            sub_graph.add_edge(u, v, edge_val) if @adj[u].key?(v) && nodes.include?(v)
          end
          return sub_graph
        end
      else
        raise ArgumentError, 'Expected Argument to be Array or Set of nodes, '\
                            "received #{nodes.class.name} instead."
      end
    end

    def edge_subgraph(edges)
      case edges
      when Array, Set
        sub_graph = NetworkX::DiGraph.new(@graph)
        edges.each do |u, v|
          raise KeyError, "#{u} does not exist in the graph!" unless @nodes.key?(u)
          raise KeyError, "#{v} does not exist in the graph!" unless @nodes.key?(v)
          raise KeyError, "Edge between #{u} and #{v} does not exist in the graph!" unless @adj[u].key?(v)
          sub_graph.add_node(u, @nodes[u])
          sub_graph.add_node(v, @nodes[v])
          sub_graph.add_edge(u, v, @adj[u][v])
        end
        return sub_graph
      else
        raise ArgumentError, 'Expected Argument to be Array or Set of edges, '\
        "received #{edges.class.name} instead."
      end
    end
  end
end