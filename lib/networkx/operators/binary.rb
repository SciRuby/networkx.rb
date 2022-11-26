module NetworkX
  # Returns the edges of the graph in an array
  def self.get_edges(graph)
    edges = []
    if graph.is_a?(MultiGraph)
      graph.adj.each do |u, v_keys|
        v_keys.each do |v, key_attrs|
          next if u > v

          key_attrs.each do |_key, attributes|
            edges << [u, v, attributes]
          end
        end
      end
    else
      graph.adj.each do |u, u_attrs|
        u_attrs.each do |v, uv_attrs|
          edges << [u, v, uv_attrs]
        end
      end
    end
    edges
  end

  # Transforms the labels of the nodes of the graphs
  # so that they are disjoint.
  def self.convert_to_distinct_labels(graph, starting_int = -1)
    new_graph = graph.class.new

    idx_dict = graph.nodes(data: true).keys.to_h do |v|
      starting_int += 1
      [v, starting_int]
    end

    graph.nodes(data: true).each do |u, attrs|
      new_graph.add_node(u.to_s + idx_dict[u].to_s, **attrs)
    end

    graph.adj.each do |u, u_edges|
      u_edges.each do |v, uv_attrs|
        if graph.multigraph?
          uv_attrs.each do |_k, attrs|
            new_graph.add_edge(u.to_s + idx_dict[u].to_s, v.to_s + idx_dict[v].to_s, **attrs)
          end
        else
          new_graph.add_edge(u.to_s + idx_dict[u].to_s, v.to_s + idx_dict[v].to_s, **uv_attrs)
        end
      end
    end
    new_graph
  end

  # Performs the intersection of two graphs
  #
  # @param g1 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param g2 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the intersection of the two graphs
  def self.intersection(g1, g2)
    result = g1.class.new

    raise ArgumentError, 'Arguments must be both Graphs or MultiGraphs!' unless g1.multigraph? == g2.multigraph?

    unless (g1.nodes(data: true).keys - g2.nodes(data: true).keys).empty?
      raise ArgumentError, 'Node sets must be equal!'
    end

    g1.nodes(data: true).each { |u, attrs| result.add_node(u, **attrs) }

    g1, g2 = g2, g1 if g1.number_of_edges > g2.number_of_edges
    g1.adj.each do |u, u_edges|
      u_edges.each do |v, uv_attrs|
        if g1.multigraph?
          next if u > v && g1.instance_of?(MultiGraph)

          uv_attrs.each do |k, attrs|
            result.add_edge(u, v, **attrs) if g2.edge?(u, v, k)
          end
        elsif g2.edge?(u, v)
          result.add_edge(u, v, **uv_attrs)
        end
      end
    end
    result
  end

  # Performs the difference of two graphs
  #
  # @param g1 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param g2 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the difference of the two graphs
  def self.difference(g1, g2)
    result = g1.class.new

    raise ArgumentError, 'Arguments must be both Graphs or MultiGraphs!' unless g1.multigraph? == g2.multigraph?

    unless (g1.nodes(data: true).keys - g2.nodes(data: true).keys).empty?
      raise ArgumentError, 'Node sets must be equal!'
    end

    g1.nodes(data: true).each { |u, attrs| result.add_node(u, **attrs) }

    g1.adj.each do |u, u_edges|
      u_edges.each do |v, uv_attrs|
        if g1.multigraph?
          next if u > v && g1.instance_of?(MultiGraph)

          uv_attrs.each do |k, attrs|
            result.add_edge(u, v, **attrs) unless g2.edge?(u, v, k)
          end
        else
          result.add_edge(u, v, **uv_attrs) unless g2.edge?(u, v)
        end
      end
    end
    result
  end

  # Performs the symmetric difference of two graphs
  #
  # @param g1 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param g2 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the symmetric difference of the two graphs
  def self.symmetric_difference(g1, g2)
    result = g1.class.new

    raise ArgumentError, 'Arguments must be both Graphs or MultiGraphs!' unless g1.multigraph? == g2.multigraph?

    unless (g1.nodes(data: true).keys - g2.nodes(data: true).keys).empty?
      raise ArgumentError, 'Node sets must be equal!'
    end

    g1.nodes(data: true).each { |u, attrs| result.add_node(u, **attrs) }

    g1.adj.each do |u, u_edges|
      u_edges.each do |v, uv_attrs|
        if g1.multigraph?
          next if u > v && g1.instance_of?(MultiGraph)

          uv_attrs.each do |k, attrs|
            result.add_edge(u, v, **attrs) unless g2.edge?(u, v, k)
          end
        else
          result.add_edge(u, v, **uv_attrs) unless g2.edge?(u, v)
        end
      end
    end

    g2.adj.each do |u, u_edges|
      u_edges.each do |v, uv_attrs|
        next if u > v && g1.instance_of?(MultiGraph)

        if g2.multigraph?
          uv_attrs.each do |k, attrs|
            result.add_edge(u, v, **attrs) unless g1.edge?(u, v, k)
          end
        else
          result.add_edge(u, v, **uv_attrs) unless g1.edge?(u, v)
        end
      end
    end
    result
  end

  # Performs the composition of two graphs
  #
  # @param g1 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param g2 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the composition of the two graphs
  def self.compose(g1, g2)
    result = g1.class.new

    raise ArgumentError, 'Arguments must be both Graphs or MultiGraphs!' unless g1.multigraph? == g2.multigraph?

    result.add_nodes(g1.nodes(data: true).map { |u, attrs| [u, attrs] })
    result.add_nodes(g2.nodes(data: true).map { |u, attrs| [u, attrs] })

    if g1.multigraph?
      g1.adj.each { |u, e| e.each { |v, uv_edges| uv_edges.each_value { |attrs| result.add_edge(u, v, **attrs) } } }
      g2.adj.each { |u, e| e.each { |v, uv_edges| uv_edges.each_value { |attrs| result.add_edge(u, v, **attrs) } } }
    else
      g1.adj.each { |u, u_edges| u_edges.each { |v, attrs| result.add_edge(u, v, **attrs) } }
      g2.adj.each { |u, u_edges| u_edges.each { |v, attrs| result.add_edge(u, v, **attrs) } }
    end
    result
  end

  # Performs the union of two graphs
  #
  # @param g1 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param g2 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the union of the two graphs
  def self.union(g1, g2)
    raise ArgumentError, 'Arguments must be both Graphs or MultiGraphs!' unless g1.multigraph? == g2.multigraph?

    new_graph = g1.class.new
    new_graph.graph.merge!(g1.graph)
    new_graph.graph.merge!(g2.graph)

    unless (g1.nodes(data: true).keys & g2.nodes(data: true).keys).empty?
      raise ArgumentError, 'Graphs must be disjoint!'
    end

    g1_edges = get_edges(g1)
    g2_edges = get_edges(g2)

    new_graph.add_nodes(g1.nodes(data: true).keys)
    new_graph.add_edges(g1_edges)
    new_graph.add_nodes(g2.nodes(data: true).keys)
    new_graph.add_edges(g2_edges)

    new_graph
  end

  # Performs the disjoint union of two graphs
  #
  # @param g1 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.1
  # @param g2 [Graph, DiGraph, MultiGraph, MultiDiGraph] graph no.2
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] the disjoint union of the two graphs
  def self.disjoint_union(g1, g2)
    new_g1 = convert_to_distinct_labels(g1)
    new_g2 = convert_to_distinct_labels(g2)
    result = union(new_g1, new_g2)
    result.graph.merge!(g1.graph)
    result.graph.merge!(g2.graph)
    result
  end
end
