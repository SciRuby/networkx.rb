RSpec.describe NetworkX do
  it 'balanced_tree' do
    balanced_tree = NetworkX::Graph.balanced_tree(3, 2)
    expect(balanced_tree.number_of_nodes).to be 13
    expect(balanced_tree.number_of_edges).to be 12
  end

  it 'barbell_graph' do
    barbell_graph = NetworkX::Graph.barbell_graph(5, 2)
    expect(barbell_graph.number_of_nodes).to be 12 # 5 * 2 + 2
    expect(barbell_graph.number_of_edges).to be 23 # (5 * (5 - 1) / 2 * 2) + 2 + 1
  end

  it 'complete_graph' do
    complete_graph = NetworkX::Graph.complete_graph(6)
    expect(complete_graph.number_of_nodes).to be 6  # 6
    expect(complete_graph.number_of_edges).to be 15 # 6 * (6 - 1) / 2
  end

  it 'circular_ladder_graph' do
    circular_ladder_graph = NetworkX::Graph.circular_ladder_graph(10)
    expect(circular_ladder_graph.number_of_nodes).to be 20 # 10 * 2
    expect(circular_ladder_graph.number_of_edges).to be 30 # 10 * 3
  end

  it 'cycle_graph' do
    cycle_graph = NetworkX::Graph.cycle_graph(10)
    expect(cycle_graph.number_of_nodes).to be 10 # 10
    expect(cycle_graph.number_of_edges).to be 10 # 10
  end

  it 'empty_graph' do
    empty_graph = NetworkX::Graph.empty_graph(10)
    expect(empty_graph.number_of_nodes).to be 10 # 10
    expect(empty_graph.number_of_edges).to be 0 # 10
  end

  it 'ladder_graph' do
    ladder_graph = NetworkX::Graph.ladder_graph(7)
    expect(ladder_graph.number_of_nodes).to be 14 # 7 * 2
    expect(ladder_graph.number_of_edges).to be 19 # 7 * 3 - 2
  end

  it 'lollipop_graph' do
    lollipop_graph = NetworkX::Graph.lollipop_graph(6, 3)
    expect(lollipop_graph.number_of_nodes).to be 9 # 6 + 3
    expect(lollipop_graph.number_of_edges).to be 18 # 6 * 5 / 2 + 3
  end

  it 'null_graph' do
    null_graph = NetworkX::Graph.null_graph
    expect(null_graph.number_of_nodes).to be 0
    expect(null_graph.number_of_edges).to be 0
  end

  it 'path_graph' do
    path_graph = NetworkX::Graph.path_graph(5)
    expect(path_graph.number_of_nodes).to be 5
    expect(path_graph.number_of_edges).to be 4
  end

  it 'star_graph' do
    star_graph = NetworkX::Graph.star_graph(5)
    expect(star_graph.number_of_nodes).to be 6 # 5 + 1
    expect(star_graph.number_of_edges).to be 5 # 5
  end

  it 'trivial_graph' do
    trivial_graph = NetworkX::Graph.trivial_graph
    expect(trivial_graph.number_of_nodes).to be 1
    expect(trivial_graph.number_of_edges).to be 0
  end

  it 'wheel_graph' do
    wheel_graph = NetworkX::Graph.wheel_graph(10)
    expect(wheel_graph.number_of_nodes).to be 10
    expect(wheel_graph.number_of_edges).to be 18
  end

  it 'bull_graph' do
    bull_graph = NetworkX::Graph.bull_graph
    expect(bull_graph.number_of_nodes).to be 5
    expect(bull_graph.number_of_edges).to be 5
  end

  it 'cubical_graph' do
    cubical_graph = NetworkX::Graph.cubical_graph
    expect(cubical_graph.number_of_nodes).to be 8
    expect(cubical_graph.number_of_edges).to be 12
  end

  it 'diamond_graph' do
    diamond_graph = NetworkX::Graph.diamond_graph
    expect(diamond_graph.number_of_nodes).to be 4
    expect(diamond_graph.number_of_edges).to be 5
  end

  it 'dodecahedral_graph' do
    dodecahedral_graph = NetworkX::Graph.dodecahedral_graph
    expect(dodecahedral_graph.number_of_nodes).to be 20
    expect(dodecahedral_graph.number_of_edges).to be 30
  end

  it 'heawood_graph' do
    heawood_graph = NetworkX::Graph.heawood_graph
    expect(heawood_graph.number_of_nodes).to be 14
    expect(heawood_graph.number_of_edges).to be 21
  end

  it 'house_graph' do
    house_graph = NetworkX::Graph.house_graph
    expect(house_graph.number_of_nodes).to be 5
    expect(house_graph.number_of_edges).to be 6
  end

  it 'house_x_graph' do
    house_x_graph = NetworkX::Graph.house_x_graph
    expect(house_x_graph.number_of_nodes).to be 5
    expect(house_x_graph.number_of_edges).to be 8
  end

  it 'moebius_kantor_graph' do
    moebius_kantor_graph = NetworkX::Graph.moebius_kantor_graph
    expect(moebius_kantor_graph.number_of_nodes).to be 16
    expect(moebius_kantor_graph.number_of_edges).to be 24
  end

  it 'octahedral_graph' do
    octahedral_graph = NetworkX::Graph.octahedral_graph
    expect(octahedral_graph.number_of_nodes).to be 6
    expect(octahedral_graph.number_of_edges).to be 12
  end

  it 'tetrahedral_graph_graph' do
    tetrahedral_graph = NetworkX::Graph.tetrahedral_graph
    expect(tetrahedral_graph.number_of_nodes).to be 4
    expect(tetrahedral_graph.number_of_edges).to be 6
  end

  it 'puts_graph_x2' do
    path_graph = NetworkX::Graph.path_graph(4)
    output = <<~'OUTPUT'
      4 3
      0 1
      1 2
      2 3
    OUTPUT
    expect { path_graph.put_graph_x2 }.to output(output).to_stdout
  end
end
