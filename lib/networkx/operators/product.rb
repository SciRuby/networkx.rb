module NetworkX
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
  def self.hash_product(d1, d2)
    Hash[(d1.keys | d2.keys).map { |n| [n, [d1[n], d2[n]]] }]
  end

  # Returns the node product of nodes of two graphs
  def self.node_product(g1, g2)
    n_product = []
    g1.nodes.each do |k1, attrs1|
      g2.nodes.each do |k2, attrs2|
        n_product << [[k1, k2], hash_product(attrs1, attrs2)]
      end
    end
    n_product
  end

  # Returns the product of directed edges with edges
  def self.directed_edges_cross_edges(g1, g2)
    result = []
    for u, v, c in edges_in_array(g1)
      for x, y, d in edges_in_array(g2)
        result << [[u, x], [v, y], hash_product(c, d)]
      end
    end
    result
  end

  # Returns the product of undirected edges with edges
  def self.undirected_edges_cross_edges(g1, g2)
    result = []
    for u, v, c in edges_in_array(g1)
      for x, y, d in edges_in_array(g2)
        result << [[v, x], [u, y], hash_product(c, d)]
      end
    end
    result
  end

  # Returns the product of edges with edges
  def self.edges_cross_nodes(g1, g2)
    result = []
    for u, v, d in edges_in_array(g1)
      for x in g2.nodes.keys
        result << [[u, x], [v, x], d]
      end
    end
    result
  end

  # Returns the product of directed nodes with edges
  def self.nodes_cross_edges(g1, g2)
    result = []
    for x in g1.nodes.keys
      for u, v, d in edges_in_array(g2)
        result << [[x, u], [x, v], d]
      end
    end
    result
  end

  # Returns the product of edges with pairs of nodes
  def self.edges_cross_nodes_and_nodes(g1, g2)
    result = []
    for u, v, d in edges_in_array(g1)
      for x in g2.nodes.keys
        for y in g2.nodes.keys
          result << [[u, x], [v, y], d]
        end
      end
    end
    result
  end

  # Initializes the product graph
  def self.init_product_graph(g1, g2)
    raise ArgumentError, 'Arguments must be both directed or undirected!' unless g1.directed? == g2.directed?

    g = if g1.multigraph? || g2.multigraph?
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
  def self.tensor_product(g1, g2)
    g = init_product_graph(g1, g2)
    g.add_nodes(node_product(g1, g2))
    g.add_edges(directed_edges_cross_edges(g1, g2))
    g.add_edges(undirected_edges_cross_edges(g1, g2)) unless g.directed?
    g
  end

  # Returns the cartesian product of two graphs
  #
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the cartesian product of the two graphs
  def self.cartesian_product(g1, g2)
    g = init_product_graph(g1, g2)
    g.add_nodes(node_product(g1, g2))
    g.add_edges(edges_cross_nodes(g1, g2))
    g.add_edges(nodes_cross_edges(g1, g2))
    g
  end

  # Returns the lexicographic product of two graphs
  #
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the lexicographic product of the two graphs
  def self.lexicographic_product(g1, g2)
    g = init_product_graph(g1, g2)
    g.add_nodes(node_product(g1, g2))
    g.add_edges(edges_cross_nodes_and_nodes(g1, g2))
    g.add_edges(nodes_cross_edges(g1, g2))
    g
  end

  # Returns the strong product of two graphs
  #
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the strong product of the two graphs
  def self.strong_product(g1, g2)
    g = init_product_graph(g1, g2)
    g.add_nodes(node_product(g1, g2))
    g.add_edges(nodes_cross_edges(g1, g2))
    g.add_edges(edges_cross_nodes(g1, g2))
    g.add_edges(directed_edges_cross_edges(g1, g2))
    g.add_edges(undirected_edges_cross_edges(g1, g2)) unless g.directed?
    g
  end

  # Returns the specified power of the
  #
  # @param [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param [Numeric] the power to which to raise the graph to
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the power of the graph
  def self.power(graph, k)
    raise ArgumentError, 'Power must be a positive quantity!' if k <= 0
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
        break if k <= level
        level += 1
      end
      result.add_edges(seen.map { |v, _| [n, v] })
    end
    result
  end
end
