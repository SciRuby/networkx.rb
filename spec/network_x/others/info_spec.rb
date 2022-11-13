RSpec.describe NetworkX do
  it 'test info method' do
    output = <<~'OUTPUT'
      Type: NetworkX::Graph
      Number of nodes: 0
      Number of edges: 0
    OUTPUT

    graph = NetworkX::Graph.new
    expect(NetworkX.info(graph)).to eq(output)
  end
end
