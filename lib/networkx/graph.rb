module NetworkX
  # Describes the class for making Undirected Graphs
  #
  # @attr_reader adj [Hash{ Object => Hash{ Object => Hash{ Object => Object } } }]
  #                  Stores the edges and their attributes in an adjencency list form
  # @attr_reader graph [Hash{ Object => Object }] Stores the attributes of the graph
  class Graph
    attr_reader :adj, :graph

    # Constructor for initializing graph
    #
    # @example Initialize a graph with attributes 'type' and 'name'
    #   graph = NetworkX::Graph.new(name: "Social Network", type: "undirected")
    #
    # @param graph_attrs [Hash{ Object => Object }] the graph attributes in a hash format
    def initialize(**graph_attrs)
      @nodes = {}
      @adj = {}
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
    # @param node1 [Object] the first node of the edge
    # @param node2 [Object] the second node of the edge
    # @param edge_attrs [Hash{ Object => Object }] the hash of the edge attributes
    def add_edge(node1, node2, **edge_attrs)
      add_node(node1)
      add_node(node2)

      edge_attrs = (@adj[node1][node2] || {}).merge(edge_attrs)
      @adj[node1][node2] = edge_attrs
      @adj[node2][node1] = edge_attrs
    end

    # Adds multiple edges from an array
    #
    # @example Add multiple edges without any attributes
    #   graph.add_edges([['Nagpur', 'Kgp'], ['Noida', 'Kgp']])
    # @param edges [Array<Object, Object>]
    def add_edges(edges)
      case edges
      when Array
        edges.each { |node1, node2, attrs| add_edge(node1, node2, **(attrs || {})) }
      else
        raise ArgumentError, 'Expected argument to be an Array of edges, ' \
                             "received #{edges.class.name} instead."
      end
    end

    def add_edges_from(rng)
      rng.each { |node| add_edge(*node) }
    end

    # Adds a node and its attributes to the graph
    #
    # @example Add a node with attribute 'type'
    #   graph.add_node("Noida", type: "city")
    #
    # @param node [Object] the node object
    # @param node_attrs [Hash{ Object => Object }] the hash of the attributes of the node
    def add_node(node, **node_attrs)
      if @nodes.has_key?(node)
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
        nodes.each { |node, node_attrs| add_node(node, **(node_attrs || {})) }
      when Range
        nodes.each { |node| add_node(node) }
      else
        raise ArgumentError, 'Expected argument to be an Array/Set/Range of nodes, ' \
                             "received #{nodes.class.name} instead."
      end
    end

    # [TODO][EXPERIMENTAL]
    #
    # @param nodes_for_adding [Array | Range | String] nodes
    def add_nodes_from(nodes_for_adding)
      case nodes_for_adding
      when String
        nodes_for_adding.each_char { |node| add_node(node) }
      else
        nodes_for_adding.each { |node| add_node(node) }
      end
    end

    def add_path(paths)
      paths.each_cons(2){|x, y| add_edge(x, y) }
    end

    # Removes node from the graph
    #
    # @example
    #   graph.remove_node("Noida")
    #
    # @param node [Object] the node to be removed
    def remove_node(node)
      raise KeyError, "Error in deleting node #{node} from Graph." unless @nodes.has_key?(node)

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
        raise ArgumentError, 'Expected argument to be an Array or Set of nodes, ' \
                             "received #{nodes.class.name} instead."
      end
    end
    alias remove_nodes_from remove_nodes

    # Removes edge from the graph
    #
    # @example
    #   graph.remove_edge('Noida', 'Bangalore')
    #
    # @param node1 [Object] the first node of the edge
    # @param node2 [Object] the second node of the edge
    def remove_edge(node1, node2)
      raise KeyError, "#{node1} is not a valid node." unless @nodes.has_key?(node1)
      raise KeyError, "#{node2} is not a valid node" unless @nodes.has_key?(node2)
      raise KeyError, 'The given edge is not a valid one.' unless @adj[node1].has_key?(node2)

      @adj[node1].delete(node2)
      @adj[node2].delete(node1) if node1 != node2
    end

    # Removes multiple edges from the graph
    #
    # @example
    #   graph.remove_edges([%w[Noida Bangalore], %w[Bangalore Chennai]])
    #
    # @param edges [Array<Object>] the array of edges to be removed
    def remove_edges(edges)
      case edges
      when Array, Set
        edges.each { |node1, node2| remove_edge(node1, node2) }
      else
        raise ArgumentError, 'Expected Arguement to be Array or Set of edges, ' \
                             "received #{edges.class.name} instead."
      end
    end
    alias remove_edges_from remove_edges

    # Adds weighted edge
    #
    # @example
    #   graph.add_weighted_edge('Noida', 'Bangalore', 1000)
    #
    # @param node1 [Object] the first node of the edge
    # @param node2 [Object] the second node of the edge
    # @param weight [Integer] the weight value
    def add_weighted_edge(node1, node2, weight)
      add_edge(node1, node2, weight: weight)
    end

    # Adds multiple weighted edges
    #
    # @example
    #   graph.add_weighted_edges([['Noida', 'Bangalore'],
    #                             ['Noida', 'Nagpur']], [1000, 2000])
    #
    # @param edges [Array<Object, Object>] the array of edges
    # @param weights [Array<Integer>] the array of weights
    def add_weighted_edges(edges, weights)
      raise ArgumentError, 'edges and weights array must have equal number of elements.' \
                           unless edges.size == weights.size
      raise ArgumentError, 'edges and weight must be given in an Array.' \
                           unless edges.is_a?(Array) && weights.is_a?(Array)

      (edges.transpose << weights).transpose.each do |node1, node2, weight|
        add_weighted_edge(node1, node2, weight)
      end
    end

    # [TODO][EXPERIMENTAL]
    #
    # @param edges [[Object, Object, Integer|Float]] the weight of edge
    # @param weight [Symbol] weight name key. default key is `:weight``
    def add_weighted_edges_from(edges, weight: :weight)
      edges.each do |s, t, w|
        add_edge(s, t, **{weight => w})
      end
    end

    # [TODO] Current default of `data` is true.
    # [Alert] Change the default in the futher. Please specify the `data`.
    #
    # @param data [bool] true if you want data of each edge
    #
    # @return [Hash | Array] if data is true, it returns hash including data.
    #                        otherwise, simple nodes array.
    def nodes(data: true)
      if data
        @nodes
      else
        @nodes.keys
      end
    end

    def each_node(data: false, &block)
      return enum_for(:each_node, data: data) unless block_given?

      data ? @nodes.each(&block) : @nodes.each_key(&block)
    end

    # [TODO][EXPERIMENTAL]
    #
    # @param data [bool] true if you want data of each edge
    #
    # @return [Array[[Object, Object]]] edges array
    def edges(data: false)
      each_edge(data: data).to_a
    end

    # [TODO][EXPERIMENTAL]
    #
    # @param data [bool] true if you want data of each edge
    def each_edge(data: false)
      return enum_for(:each_edge, data: data) unless block_given?

      h = {}
      @adj.each do |v, ws|
        ws.each do |w, info|
          next if v > w

          h[[v, w, info]] = true
        end
      end
      if data
        h.each { |(v, w, info), _true| yield(v, w, info) }
      else
        h.each { |(v, w, _info), _true| yield(v, w) }
      end
    end

    # Clears the graph
    #
    # @example
    #   graph.clear
    def clear
      @adj.clear
      @nodes.clear
      @graph.clear
    end

    # Checks if a node is present in the graph
    #
    # @example
    #   graph.node?(node1)
    #
    # @param node [Object] the node to be checked
    def node?(node)
      @nodes.has_key?(node)
    end
    alias has_node? node?

    # Checks if the the edge consisting of two nodes is present in the graph
    #
    # @example
    #   graph.edge?(node1, node2)
    #
    # @param node1 [Object] the first node of the edge to be checked
    # @param node2 [Object] the second node of the edge to be checked
    def edge?(node1, node2)
      node?(node1) && @adj[node1].has_key?(node2)
    end
    alias has_edge? edge?

    # Gets the node data
    #
    # @example
    #   graph.get_node_data(node)
    #
    # @param node [Object] the node whose data is to be fetched
    def get_node_data(node)
      raise ArgumentError, 'No such node exists!' unless node?(node)

      @nodes[node]
    end

    # Gets the edge data
    #
    # @example
    #   graph.get_edge_data(node1, node2)
    #
    # @param node1 [Object] the first node of the edge
    # @param node2 [Object] the second node of the edge
    def get_edge_data(node1, node2)
      raise KeyError, 'No such edge exists!' unless node?(node1) && node?(node2)

      @adj[node1][node2]
    end

    # Retus a hash of neighbours of a node
    #
    # @example
    #   graph.neighbours(node)
    #
    # @param node [Object] the node whose neighbours are to be fetched
    def neighbours(node)
      raise KeyError, 'No such node exists!' unless node?(node)

      @adj[node]
    end

    # Returns number of nodes
    #
    # @example
    #   graph.number_of_nodes
    def number_of_nodes
      @nodes.length
    end

    # Returns number of edges
    #
    # @example
    #   graph.number_of_edges
    def number_of_edges
      @adj.values.map(&:length).sum / 2
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
          hash_val.each { |_, v| graph_size += v[:weight] if v.has_key?(:weight) }
        end
        return graph_size / 2
      end
      number_of_edges
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
        sub_graph = NetworkX::Graph.new(**@graph)
        nodes.each do |u, _|
          raise KeyError, "#{u} does not exist in the current graph!" unless @nodes.has_key?(u)

          sub_graph.add_node(u, **@nodes[u])
          @adj[u].each do |v, edge_val|
            sub_graph.add_edge(u, v, **edge_val) if @adj[u].has_key?(v) && nodes.include?(v)
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
        sub_graph = NetworkX::Graph.new(**@graph)
        edges.each do |u, v|
          raise KeyError, "Edge between #{u} and #{v} does not exist in the graph!" unless @nodes.has_key?(u) \
                                                                                    && @adj[u].has_key?(v)

          sub_graph.add_node(u, **@nodes[u])
          sub_graph.add_node(v, **@nodes[v])
          sub_graph.add_edge(u, v, **@adj[u][v])
        end
        sub_graph
      else
        raise ArgumentError, 'Expected Argument to be Array or Set of edges, ' \
                             "received #{edges.class.name} instead."
      end
    end

    # [EXPERIMENTAL]
    def degree(nodes = nil)
      if nodes.nil?
        @adj.transform_values(&:size)
      else
        res = {}
        nodes.each { |node| res[node] = @adj[node].size }
        res
      end
    end

    def info
      info = ''
      info << "Type: #{self.class}\n"
      info << "Number of nodes: #{number_of_nodes}\n"
      info << "Number of edges: #{number_of_edges}\n"
      info
    end

    def multigraph?
      ['NetworkX::MultiGraph', 'NetworkX::MultiDiGraph'].include?(self.class.name)
    end

    def directed?
      ['NetworkX::DiGraph', 'NetworkX::MultiDiGraph'].include?(self.class.name)
    end
  end
end
