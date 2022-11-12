RSpec.describe NetworkX do
  it 'test number_connected methods' do
    graph = NetworkX::Graph.new
    graph.add_nodes_from('a'..'z')

    expect(NetworkX.number_of_connected_components(graph)).to be 26

    graph.add_edge('a', 'j')
    graph.add_edge('j', 't')
    expect(NetworkX.number_of_connected_components(graph)).to be 24
  end
end
