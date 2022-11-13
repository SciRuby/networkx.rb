# Undirected Graph
RSpec.describe NetworkX::Graph do
  it 'cycle?' do
    undirected_graph = NetworkX::Graph.new
    expect(NetworkX.cycle?(undirected_graph)).to be false

    undirected_graph.add_edge(0, 1)
    expect(NetworkX.cycle?(undirected_graph)).to be false

    undirected_graph.add_edge(1, 2)
    expect(NetworkX.cycle?(undirected_graph)).to be false

    undirected_graph.add_edge(2, 0)
    expect(NetworkX.cycle?(undirected_graph)).to be_truthy
  end
end
