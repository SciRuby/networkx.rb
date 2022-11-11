require_relative '../auxillary_functions/union_find'

module NetworkX
  # @return [[Object, Object]] bridges
  #
  # @param graph [Graph] Graph
  def self.bridges(graph)
    each_bridge(graph).to_a
  end

  # @param graph [Graph] Graph
  def self.each_bridge(graph)
    return enum_for(:each_bridge, graph) unless block_given?

    graph.each_edge.with_index do |(s_i, t_i), i|
      uf = UnionFind.new(1..graph.number_of_nodes)
      graph.each_edge.with_index do |(s_j, t_j), j|
        uf.unite(s_j, t_j) if i != j
      end
      yield [s_i, t_i] unless uf.same?(s_i, t_i)
    end
  end

  # @return [Integer] the number of bridges
  #
  # @param graph [Graph] Graph
  def self.number_of_bridges(graph)
    bridges(graph).size
  end
end
