require_relative '../graph'

module NetworkX
  def self.info(graph)
    info = ''
    info << "Type: #{graph.class}\n"
    info << "Number of nodes: #{graph.number_of_nodes}\n"
    info << "Number of edges: #{graph.number_of_edges}\n"
    info
  end
end
