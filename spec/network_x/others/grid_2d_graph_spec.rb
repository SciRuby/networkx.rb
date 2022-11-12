RSpec.describe NetworkX do
  it 'test grid_2d_graph for simple square Graph' do
    grid_graph = NetworkX.grid_2d_graph(2, 2)
    expect(grid_graph.number_of_nodes).to be 4
    expect(grid_graph.number_of_edges).to be 4
  end

  it 'test grid_2d_graph for simple Graph' do
    grid_graph = NetworkX.grid_2d_graph(3, 6)
    expect(grid_graph.number_of_nodes).to be 3 * 6
    expect(grid_graph.number_of_edges).to be (3 - 1) * 6 + 3 * (6 - 1)
    expect(grid_graph.number_of_edges).to be(3 * 6 * 2 - 3 - 6)
  end

  it 'test grid_2d_graph for DiGraph' do
    grid_di_graph = NetworkX.grid_2d_graph(5, 4, create_using: NetworkX::DiGraph)
    expect(grid_di_graph.number_of_nodes).to be 5 * 4
    expect(grid_di_graph.number_of_edges).to be (5 * 4 * 2 - 5 - 4) * 2
  end

  it 'test grid_2d_graph for simple MultiGraph' do
    grid_graph = NetworkX.grid_2d_graph(3, 6, create_using: NetworkX::MultiGraph)
    expect(grid_graph.number_of_nodes).to be 3 * 6
    expect(grid_graph.number_of_edges).to be (3 - 1) * 6 + 3 * (6 - 1)
    expect(grid_graph.number_of_edges).to be(3 * 6 * 2 - 3 - 6)
  end

  it 'test grid_2d_graph for MultiDiGraph' do
    grid_di_graph = NetworkX.grid_2d_graph(5, 4, create_using: NetworkX::MultiDiGraph)
    expect(grid_di_graph.number_of_nodes).to be 5 * 4
    expect(grid_di_graph.number_of_edges).to be (5 * 4 * 2 - 5 - 4) * 2
  end
end
