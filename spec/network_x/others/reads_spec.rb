RSpec.describe NetworkX do
  it 'Graph#read_edgelist' do
    graph = NetworkX::Graph.read_edges('spec/network_x/others/inputs/edges.txt')
    expect(graph.number_of_nodes).to be 6
    expect(graph.number_of_edges).to be 6
  end

  it 'Graph#read_weighted_edges' do
    graph = NetworkX::Graph.read_weighted_edges('spec/network_x/others/inputs/weighted_edges.txt')
    expect(graph.number_of_nodes).to be 6
    expect(graph.number_of_edges).to be 6
    expect(graph.get_edge_data(1, 3)).to eq({weight: 5})
  end
end
