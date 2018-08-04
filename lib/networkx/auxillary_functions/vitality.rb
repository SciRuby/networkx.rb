module NetworkX
  def self.closeness_vitality(graph, node)
    before = wiener_index(graph)
    after = wiener_index(graph.subgraph(graph.nodes.keys - [node]))
    before - after
  end
end