module NetworkX
  # Describes the class for making Undirected Graphs
  #
  # @attr_reader adj [Hash{ Object => Hash{ Object => Hash{ Object => Object } } }]
  #                  Stores the edges and their attributes in an adjencency list form
  # @attr_reader nodes [Hash{ Object => Hash{ Object => Object } }] Stores the nodes and their attributes
  # @attr_reader graph [Hash{ Object => Object }] Stores the attributes of the graph
  class Graph
    attr_reader :adj, :nodes, :graph

    # Constructor for initializing graph
    #
    # @example Initialize a graph with attributes 'type' and 'name'
    #   graph = NetworkX::Graph.new(name: "Social Network", type: "undirected")
    #
    # @param graph_attrs [Hash{ Object => Object }] the graph attributes in a hash format
    def initialize(**graph_attrs)
      @nodes = {}
      @adj = {}
      @graph = {}

      @graph = graph_attrs
    end

    # Adds the respective edges
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

      edge_attrs = (@adj[node_1][node_2] || {}).merge(edge_attrs)
      @adj[node_1][node_2] = edge_attrs
      @adj[node_2][node_1] = edge_attrs
    end

    # Adds multiple edges from an array
    #
    # @example Add multiple edges without any attributes
    #   graph.add_edges([['Nagpur', 'Kgp'], ['Noida', 'Kgp']])
    # @param edges [Array<Object, Object>]
    def add_edges(edges)
      case edges
      when Array
        edges.each { |node_1, node_2, **attrs| add_edge(node_1, node_2, **attrs) }
      else
        raise ArgumentError, 'Expected argument to be an Array of edges, '\
                             "received #{edges.class.name} instead."
      end
    end

    # Adds a node and its attributes to the graph
    #
    # @example Add a node with attribute 'type'
    #   graph.add_node("Noida", type: "city")
    #
    # @param node [Object] the node object
    # @param node_attrs [Hash{ Object => Object }] the hash of the attributes of the node
    def add_node(node, **node_attrs)
      if @nodes.key?(node)
        @nodes[node].merge!(node_attrs)
      else
        @adj[node] = {}
        @nodes[node] = node_attrs
      end
    end

    # Adds multiple nodes to the graph
    #
    # @example Adds multiple nodes with attribute 'type'
    #   graph.add_nodes([["Noida", type: "city"], ["Kgp", type: "town"]])
    #
    # @param nodes [Array<Object, Hash{ Object => Object }>] the Array of pair containing nodes and its attributes
    def add_nodes(nodes)
      case nodes
      when Set, Array
        nodes.each { |node, **node_attrs| add_node(node, node_attrs) }
      else
        raise ArgumentError, 'Expected argument to be an Array or Set of nodes, '\
                             "received #{nodes.class.name} instead."
      end
    end

    # Removes node from the graph
    #
    # @example
    #   graph.remove_node("Noida")
    #
    # @param node [Object] the node to be removed
    def remove_node(node)
      raise KeyError, "Error in deleting node #{node} from Graph." unless @nodes.key?(node)
      @adj[node].each_key { |k| @adj[k].delete(node) }
      @adj.delete(node)
      @nodes.delete(node)
    end

    # Removes multiple nodes from the graph
    #
    # @example
    #   graph.remove_nodes(["Noida", "Bangalore"])
    #
    # @param nodes [Array<Object>] the array of nodes to be removed
    def remove_nodes(nodes)
      case nodes
      when Set, Array
        nodes.each { |node| remove_node(node) }
      else
        raise ArgumentError, 'Expected argument to be an Array or Set of nodes, '\
                             "received #{nodes.class.name} instead."
      end
    end

    def remove_edge(node_1, node_2)
      raise KeyError, "#{node_1} is not a valid node." unless @nodes.key?(u)
      raise KeyError, "#{node_2} is not a valid node" unless @nodes.key?(v)
      raise KeyError, "The given edge is not a valid one." unless @adj[node_1].key?(node_2)
      @adj[node_1].delete(node_2)
      if node_1 != node_2
        @[node_2].delete(node_1)
      end
    end

    def remove_edges(edges)
      case edges
      when Array, Set
        edges.each { |node_1, node_2| remove_edge(node_1, node_2) }
      else
        raise ArgumentError, "Expected Arguement to be Array or Set of edges, "\
                             "received #{edges.class.name} instead."
      end
    end

    def add_weighted_edge(node_1, node_2, weight)
      add_edge(node_1, node_2, weight: weight)
    end

    def add_weighted_edges(edges, weights)
      raise ArgumentError, "edges and weights array must have equal number of elements." unless edges.size == weights.size
      if edges.is_a?(Array) && weights.is_a?(Array)
        (edges.transpose << weights).transpose.each { |node_1, node_2, weight|
          add_weighted_edge(node_1, node_2, weight)
        }
      else
        raise ArgumentError, "edges and weight must be given in an Array."
      end
    end

    def clear
      @adj.clear
      @nodes.clear
      @graph.clear
    end

    def nodes
      @nodes
    end

    def adj
      @adj
    end

    def has_node(node)
      @node.key?(node)
    end

    def has_edge(node_1, node_2)
      return true if @nodes.key?(node_1) and @adj[node_1].key?(node_2)
      return false
    end

    def get_node_data(node)
      return @nodes[node] if @nodes.key?(node)
      raise ArgumentError, "No such node exists!"
    end

    def get_edge_data(node_1, node_2)
      return @adj[node_1][node_2] if @nodes.key?(node_1) and @adj[node_1].key?(node_2)
      raise ArgumentError, "No such edge exists!"
    end

    def neighbours(node)
      return @adj[node] if @nodes.key?(node)
      raise ArgumentError, "No such node exists!"
    end

    def number_of_nodes
      return @nodes.length
    end

    def number_of_edges
      num = 0
      @adj.each { |u| num += u.length }
      return num
    end

    def size(is_weighted=false)
      if is_weighted
        graph_size = 0
        @adj.each { |u|
          u.each { |v|
            graph_size += v[:weight] if v.key?(weight)
          }
        }
        return graph_size
      else
        return number_of_edges
      end
    end

    def subgraph(nodes)
      case nodes
      when Array, Set
        subGraph = NetworkX::Graph.new(@graph)
        nodes.each { |u| 
          if @nodes.key?(u)
            subGraph.add_node(u, @nodes[u])
            @adj[u].each { |v|
              subGraph.add_edge(u, v, @adj[u][v]) if @adj[u].key?(v)
            }
            return subGraph
          else
            raise ArgumentError, "#{u} does not exist in the current graph!"
          end
        }
      else
        raise ArgumentError, "Expected Argument to be Array or Set of nodes, "\
                             "received #{nodes.class.name} instead."
      end
    end

    def edge_subgraph(edges)
      case edges
      when Array, Set
        subGraph = NetworkX::Graph.new(@graph)
        edges.each { |u, v|
          raise ArgumentError, "#{u} does not exist in the graph!" unless @nodes.key?(u)
          raise ArgumentError, "#{v} does not exist in the graph!" unless @nodes.key?(v)
          raise ArgumentError, "Edge between #{u} and #{v} does not exist in the graph!" unless @adj[u].key?(v)
          subGraph.add_node(u, @nodes[u])
          subGraph.add_node(v, @nodes[v])
          subGraph.add_edge(u, v, @adj[u][v])
        }
        return subGraph
      else
        raise ArgumentError, "Expected Argument to be Array or Set of edges, "\
        "received #{edges.class.name} instead."
    end
  end
end
