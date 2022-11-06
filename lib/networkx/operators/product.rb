# frozen_string_literal: true

# TODO: Reduce module length

module NetworkX
  # TODO: Reduce method length

  # Returns the edges of the graph in an array
  def self.edges_in_array(graph)
    edge_array = []
    if graph.multigraph?
      graph.adj.each do |u, u_edges|
        u_edges.each do |v, uv_edges|
          uv_edges.each do |_k, attrs|
            edge_array << [u, v, attrs]
          end
        end
      end
    else
      graph.adj.each do |u, u_edges|
        u_edges.each do |v, attrs|
          edge_array << [u, v, attrs]
        end
      end
    end
    edge_array
  end

  # Returns the hash product of two hashes
  def self.hash_product(hash_1, hash_2)
    (hash_1.keys | hash_2.keys).to_h { |n| [n, [hash_1[n], hash_2[n]]] }
  end

  # Returns the node product of nodes of two graphs
  def self.node_product(g_1, g_2)
    n_product = []
    g_1.nodes.each do |k_1, attrs_1|
      g_2.nodes.each do |k_2, attrs_2|
        n_product << [[k_1, k_2], hash_product(attrs_1, attrs_2)]
      end
    end
    n_product
  end

  # Returns the product of directed edges with edges
  def self.directed_edges_cross_edges(g_1, g_2)
    result = []
    edges_in_array(g_1).each do |u, v, c|
      edges_in_array(g_2) do |x, y, d|
        result << [[u, x], [v, y], hash_product(c, d)]
      end
    end
    result
  end

  # Returns the product of undirected edges with edges
  def self.undirected_edges_cross_edges(g_1, g_2)
    result = []
    edges_in_array(g_1).each do |u, v, c|
      edges_in_array(g_2).each do |x, y, d|
        result << [[v, x], [u, y], hash_product(c, d)]
      end
    end
    result
  end

  # Returns the product of edges with edges
  def self.edges_cross_nodes(g_1, g_2)
    result = []
    edges_in_array(g_1).each do |u, v, d|
      g_2.nodes.each_key do |x|
        result << [[u, x], [v, x], d]
      end
    end
    result
  end

  # Returns the product of directed nodes with edges
  def self.nodes_cross_edges(g_1, g_2)
    result = []
    g_1.nodes.each_key do |x|
      edges_in_array(g_2).each do |u, v, d|
        result << [[x, u], [x, v], d]
      end
    end
    result
  end

  # Returns the product of edges with pairs of nodes
  def self.edges_cross_nodes_and_nodes(g_1, g_2)
    result = []
    edges_in_array(g_1).each do |u, v, d|
      g_2.nodes.each_key do |x|
        g_2.nodes.each_key do |y|
          result << [[u, x], [v, y], d]
        end
      end
    end
    result
  end

  # Initializes the product graph
  def self.init_product_graph(g_1, g_2)
    raise ArgumentError, 'Arguments must be both directed or undirected!' unless g_1.directed? == g_2.directed?

    g = if g_1.multigraph? || g_2.multigraph?
          NetworkX::MultiGraph.new
        else
          NetworkX::Graph.new
        end
    g = g.to_directed if g.directed?
    g
  end

  # Returns the tensor product of two graphs
  #
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the tensor product of the two graphs
  def self.tensor_product(g_1, g_2)
    g = init_product_graph(g_1, g_2)
    g.add_nodes(node_product(g_1, g_2))
    g.add_edges(directed_edges_cross_edges(g_1, g_2))
    g.add_edges(undirected_edges_cross_edges(g_1, g_2)) unless g.directed?
    g
  end

  # Returns the cartesian product of two graphs
  #
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the cartesian product of the two graphs
  def self.cartesian_product(g_1, g_2)
    g = init_product_graph(g_1, g_2)
    g.add_nodes(node_product(g_1, g_2))
    g.add_edges(edges_cross_nodes(g_1, g_2))
    g.add_edges(nodes_cross_edges(g_1, g_2))
    g
  end

  # Returns the lexicographic product of two graphs
  #
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the lexicographic product of the two graphs
  def self.lexicographic_product(g_1, g_2)
    g = init_product_graph(g_1, g_2)
    g.add_nodes(node_product(g_1, g_2))
    g.add_edges(edges_cross_nodes_and_nodes(g_1, g_2))
    g.add_edges(nodes_cross_edges(g_1, g_2))
    g
  end

  # Returns the strong product of two graphs
  #
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the strong product of the two graphs
  def self.strong_product(g_1, g_2)
    g = init_product_graph(g_1, g_2)
    g.add_nodes(node_product(g_1, g_2))
    g.add_edges(nodes_cross_edges(g_1, g_2))
    g.add_edges(edges_cross_nodes(g_1, g_2))
    g.add_edges(directed_edges_cross_edges(g_1, g_2))
    g.add_edges(undirected_edges_cross_edges(g_1, g_2)) unless g.directed?
    g
  end

  # TODO: Reduce method complexity and method length

  # Returns the specified power of the graph
  #
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param [Numeric] the power to which to raise the graph to
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the power of the graph
  def self.power(graph, pow)
    raise ArgumentError, 'Power must be a positive quantity!' if pow <= 0

    result = NetworkX::Graph.new
    result.add_nodes(graph.nodes.map { |n, attrs| [n, attrs] })
    graph.nodes.each do |n, _attrs|
      seen = {}
      level = 1
      next_level = graph.adj[n]
      until next_level.empty?
        this_level = next_level
        next_level = {}
        this_level.each do |v, _attrs|
          next if v == n

          unless seen.key?(v)
            seen[v] = level
            next_level.merge!(graph.adj[v])
          end
        end
        break if pow <= level

        level += 1
      end
      result.add_edges(seen.map { |v, _| [n, v] })
    end
    result
  end
end
