module NetworkX
  # Describes the class for making Undirected Graphs
  # @attr_reader adj [Hash{ Object => Hash{ Object => Hash{ Object => Object } } }]
  #                  Stores the edges and their attributes in an adjencency list form
  # @attr_reader nodes [Hash{ Object => Hash{ Object => Object } }] Stores the nodes and their attributes
  # @attr_reader graph [Hash{ Object => Object }] Stores the attributes of the graph
  class Graph
    attr_reader :adj, :nodes, :graph

    # Constructor for initializing graph
    # @example Initialize a graph with attributes 'type' and 'name'
    #   graph = NetworkX::Graph.new(name: "Social Network", type: "undirected")
    # @param graph_attrs [Hash{ Object => Object }] the graph attributes in a hash format
    def initialize(**graph_attrs)
      @nodes = {}
      @adj = {}
      @graph = {}

      @graph = graph_attrs
    end

    # Adds the respective edges
    # @example Add an edge
    #   graph.add_edge(node1, node2, name: "Edge1")
    #   graph.add_edge("Bangalore", "Chennai")
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
    # @example Add a node with attribute 'type'
    #   graph.add_node("Noida", type: "city")
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
    # @example Adds multiple nodes with attribute 'type'
    #   graph.add_nodes([["Noida", type: "city"], ["Kgp", type: "town"]])
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
    # @example
    #   graph.remove_node("Noida")
    # @param node [Object] the node to be removed
    def remove_node(node)
      raise KeyError, "Error in deleting node #{node} from Graph." unless @nodes.key?(node)
      @adj[node].each_key { |k| @adj[k].delete(node) }
      @adj.delete(node)
      @nodes.delete(node)
    end

    # Removes multiple nodes from the graph
    # @example
    #   graph.remove_nodes(["Noida", "Bangalore"])
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
  end
end
