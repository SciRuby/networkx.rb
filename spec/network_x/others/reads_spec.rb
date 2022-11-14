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

  it 'to_number_if_possible' do
    expect(NetworkX.to_number_if_possible('10')).to be 10

    expect(NetworkX.to_number_if_possible('11.0')).to be 11.0
    expect(NetworkX.to_number_if_possible('1e2')).to be 100.0
    expect(NetworkX.to_number_if_possible('-25e-2')).to be -0.25

    expect(NetworkX.to_number_if_possible('e')).to eq 'e'
    expect(NetworkX.to_number_if_possible('E')).to eq 'E'
  end
end
