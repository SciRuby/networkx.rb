RSpec.describe NetworkX do
  it 'to_matrix(multi graph, val, sum)' do
    graph = NetworkX::MultiGraph.new

    graph.add_edge(1, 2, weight: 10)
    graph.add_edge(1, 2, weight: 9)

    m, _index = NetworkX.to_matrix(graph, 0)
    expect(m).to eq Matrix[[0, 19], [19, 0]]
  end

  it 'to_matrix(multi graph, val, max)' do
    graph = NetworkX::MultiGraph.new

    graph.add_edge(1, 2, weight: 10)
    graph.add_edge(1, 2, weight: 5)

    m, _index = NetworkX.to_matrix(graph, 0, 'max')
    expect(m).to eq Matrix[[0, 10], [10, 0]]
  end

  it 'to_matrix(multi graph, val, min)' do
    graph = NetworkX::MultiGraph.new

    graph.add_edge(1, 2, weight: 10)
    graph.add_edge(1, 2, weight: 5)

    m, _index = NetworkX.to_matrix(graph, 0, 'min')
    expect(m).to eq Matrix[[0, 5], [5, 0]]
  end
end
