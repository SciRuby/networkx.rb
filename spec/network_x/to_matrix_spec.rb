RSpec.describe NetworkX do
  it 'to_matrix(multi graph, val, sum)' do
    graph = NetworkX::MultiGraph.new

    graph.add_edge(:a, :b, weight: 10)
    graph.add_edge(:b, :a, weight: 9)

    m, indexes = NetworkX.to_matrix(graph, 0)
    expect(m).to eq Matrix[[0, 19], [19, 0]]
    expect(indexes).to eq({0 => :a, 1 => :b})
  end

  it 'to_matrix(multi graph, val, max)' do
    graph = NetworkX::MultiGraph.new

    graph.add_edge(:x, :y, weight: 10)
    graph.add_edge(:y, :x, weight: 5)

    m, index = NetworkX.to_matrix(graph, 0, 'max')
    expect(m).to eq Matrix[[0, 10], [10, 0]]
    expect(index).to eq({0 => :x, 1 => :y})
  end

  it 'to_matrix(multi graph, val, min)' do
    graph = NetworkX::MultiGraph.new

    graph.add_edge(:v, :w, weight: 10)
    graph.add_edge(:w, :v, weight: 5)

    m, index = NetworkX.to_matrix(graph, 0, 'min')
    expect(m).to eq Matrix[[0, 5], [5, 0]]
    expect(index).to eq({0 => :v, 1 => :w})
  end
end
