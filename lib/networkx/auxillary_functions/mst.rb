module NetworkX
  def self.get_edges_weights(graph)
    edges = []
    graph.adj.each do |u, u_edges|
      u_edges.each do |v, uv_attrs|
        edges << [[u, v], uv_attrs[:weight] || Float::INFINITY]
      end
    end
    edges
  end

  def self.minimum_spanning_tree(graph)
    mst = Marshal.load(Marshal.dump(graph))
    mst.clear
    edges = get_edges_weights(graph).sort { |x, y| x[1] <=> y[1] }
    union_find = UnionFind.new(graph.nodes.keys)
    while edges.any? && mst.nodes.length <= graph.nodes.length
      edge = edges.shift
      unless union_find.connected?(edge[0][0], edge[0][1])
        union_find.union(edge[0][0], edge[0][1])
        mst.add_edge(edge[0][0], edge[0][1], graph.adj[edge[0][0]][edge[0][1]])
      end
    end
    mst
  end
end