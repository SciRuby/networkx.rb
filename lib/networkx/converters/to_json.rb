module NetworkX
  # Returns a JSON object of the given graph
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  #
  # @return [JSON] json encoded graph
  def self.graph_to_json(graph)
    json_hash = {}
    json_hash[:class] = graph.class.name
    json_hash[:graph] = graph.graph
    json_hash[:nodes] = graph.nodes
    json_hash[:adj] = graph.adj
    json_hash.to_json
  end

  # Returns a graph from the json encoded graph
  #
  # @param json_str [JSON] json encoded string
  #
  # @return [Graph, DiGraph, MultiGraph, MultiDiGraph] a decoded graph
  def self.json_to_graph(json_str)
    graph_hash = JSON.parse(json_str)
    case json_str["class"]
    when "NetworkX::Graph"
      graph = NetworkX::Graph.new(graph_hash.graph)
    when "NetworkX::MultiGraph"
      graph = NetworkX::MultiGraph.new(graph_hash.graph)
    when "NetworkX::DiGraph"
      graph = NetworkX::DiGraph.new(graph_hash.graph)
    when "NetworkX::MultiDiGraph"
      graph = NetworkX::MultiDiGraph.new(graph_hash.graph)
    end
    graph.adj = graph_hash["adj"]
    graph.nodes = graph_hash["nodes"]
    graph
  end
end