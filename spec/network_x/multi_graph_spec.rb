RSpec.describe NetworkX::MultiGraph do
  subject { graph }

  let(:graph) { described_class.new(name: 'Cities', type: 'undirected') }

  before do
    graph.add_nodes(%w[Nagpur Mumbai])
    graph.add_edge('Nagpur', 'Mumbai')
    graph.add_edges([%w[Nagpur Chennai], %w[Chennai Bangalore]])
    graph.add_node('Kolkata')
  end

  context 'when graph has been assigned attributes' do
    its('graph') { is_expected.to eq(name: 'Cities', type: 'undirected') }
  end

  context 'when a new node/s has/have been created' do
    its('nodes') do
      is_expected.to eq('Kolkata' => {},
                        'Nagpur' => {},
                        'Mumbai' => {},
                        'Chennai' => {},
                        'Bangalore' => {})
    end
  end

  context 'when a new edge/s has/have been added' do
    its('adj') do
      is_expected.to eq('Nagpur' => {'Mumbai' => {0 => {}}, 'Chennai' => {0 => {}}},
                        'Bangalore' => {'Chennai' => {0 => {}}},
                        'Chennai' => {'Nagpur' => {0 => {}}, 'Bangalore' => {0 => {}}},
                        'Mumbai' => {'Nagpur' => {0 => {}}}, 'Kolkata' => {})
    end
  end

  it 'nodes' do
    graph = NetworkX::MultiGraph.new
    graph.add_edges([[:x, :y], [:y, :z]])
    expect(graph.nodes(data: false).sort).to eq([:x, :y, :z])
    expect(graph.nodes(data: true)).to eq({x: {}, y: {}, z: {}})
  end

  context 'when node/s is/are removed' do
    before do
      graph.remove_node('Nagpur')
      graph.remove_nodes(%w[Chennai Mumbai])
    end

    its('nodes') { is_expected.to eq('Kolkata' => {}, 'Bangalore' => {}) }
    its('adj') { is_expected.to eq('Kolkata' => {}, 'Bangalore' => {}) }
  end

  context 'when edge/s is/are removed' do
    before do
      graph.remove_edge('Nagpur', 'Mumbai')
      graph.remove_edges([%w[Nagpur Chennai], %w[Chennai Bangalore]])
    end

    its('adj') do
      is_expected.to eq('Kolkata' => {}, 'Bangalore' => {}, \
                        'Nagpur' => {}, 'Chennai' => {}, 'Mumbai' => {})
    end
  end

  it 'tests `remove_edge` with key' do
    graph = NetworkX::MultiGraph.new
    graph.add_edge(:a, :b, key: 'first')
    graph.add_edge(:a, :b, key: 'second')
    expect(graph.number_of_nodes).to be 2
    expect(graph.number_of_edges).to be 2

    graph.remove_edge(:a, :b, 'first')
    expect(graph.number_of_nodes).to be 2
    expect(graph.number_of_edges).to be 1

    expect { graph.remove_edge(:a, :b, 'third') }.to raise_error(KeyError)
  end

  context 'when weighted edge/s is/are added' do
    before do
      graph.remove_nodes(%w[Chennai Bangalore])
      graph.add_weighted_edge('Nagpur', 'Mumbai', 15)
      graph.add_weighted_edges([%w[Nagpur Kolkata]], [10])
    end

    its('adj') do
      is_expected.to eq('Kolkata' => {'Nagpur' => {0 => {weight: 10}}},
                        'Mumbai' => {'Nagpur' => {1 => {weight: 15}, 0 => {}}},
                        'Nagpur' => {'Mumbai' => {1 => {weight: 15}, 0 => {}},
                                     'Kolkata' => {0 => {weight: 10}}})
    end
  end

  context 'when number of edges are calculated' do
    before do
      graph.add_edge('Nagpur', 'Mumbai')
    end

    its('number_of_edges') do
      is_expected.to eq 4
    end
  end

  it 'test number_of_edges of empty graph returns 0' do
    empty_graph = NetworkX::MultiGraph.new
    expect(empty_graph.number_of_edges).to be 0
  end

  it 'tests edge?' do
    graph = NetworkX::MultiGraph.new
    expect(graph.has_edge?(:x, :y)).to be_falsy

    graph.add_edge(:x, :y)
    expect(graph.has_edge?(:x, :y)).to be_truthy
  end

  it 'tests edge? with key' do
    graph = NetworkX::MultiGraph.new
    expect(graph.has_edge?(:x, :y, 'first')).to be_falsy

    graph.add_edge(:x, :y, key: 'first')
    expect(graph.has_edge?(:x, :y, 'first')).to be_truthy
  end

  it 'each_edges' do
    graph = NetworkX::MultiGraph.new
    graph.add_edge(1, 2, key:'first')
    graph.add_edge(1, 2, key:'second')
    expect(graph.each_edge.to_a).to eq [[1, 2, 0], [1, 2, 1]]
  end

  context 'when size is called' do
    subject { graph.size(true) }

    before do
      graph.add_weighted_edge('Nagpur', 'Mumbai', 15)
    end

    it do
      is_expected.to eq 15
    end
  end

  it 'test size' do
    graph = NetworkX::MultiGraph.new
    expect(graph.size).to be 0
    expect(graph.size(true)).to be 0

    graph.add_edge(:s, :t, weight: 10)
    expect(graph.size).to be 1
    expect(graph.size(true)).to be 10
  end

  context 'when subgraph is called' do
    subject { graph.subgraph(%w[Nagpur Mumbai]) }

    its('nodes') do
      is_expected.to eq('Nagpur' => {}, 'Mumbai' => {})
    end

    its('adj') do
      is_expected.to eq('Nagpur' => {'Mumbai' => {0 => {}}}, 'Mumbai' => {'Nagpur' => {0 => {}}})
    end
  end

  it 'test `subgraph` method' do
    g = NetworkX::MultiGraph.new
    g.add_nodes_from(0...4)
    g.add_edges([[0, 1], [1, 2], [1, 2], [1, 3]])

    h = g.subgraph([0, 1, 2])

    expect(h.number_of_nodes).to eq 3
    expect(h.number_of_edges).to eq 3
    expect(h.edges(data: true)).to eq [[0, 1, 0, {}], [1, 2, 0, {}], [1, 2, 1, {}]]
  end

  it 'tests error from subgraph and edge_subgraph' do
    g = NetworkX::MultiGraph.new
    expect { g.subgraph(nil) }.to raise_error(ArgumentError)
    expect { g.edge_subgraph(nil) }.to raise_error(ArgumentError)
  end

  context 'when edges_subgraph is called' do
    subject { graph.edge_subgraph([%w[Nagpur Mumbai], %w[Nagpur Chennai]]) }

    its('nodes') do
      is_expected.to eq('Nagpur' => {}, 'Mumbai' => {}, 'Chennai' => {})
    end

    its('adj') do
      is_expected.to eq('Nagpur' => {'Chennai' => {0 => {}}, 'Mumbai' => {0 => {}}},
                        'Mumbai' => {'Nagpur' => {0 => {}}},
                        'Chennai' => {'Nagpur' => {0 => {}}})
    end
  end

  context 'when to_undirected is called' do
    subject { graph.to_undirected }

    its('adj') do
      is_expected.to eq('Nagpur' => {'Mumbai' => {}, 'Chennai' => {}},
                        'Bangalore' => {'Chennai' => {}},
                        'Chennai' => {'Nagpur' => {}, 'Bangalore' => {}},
                        'Mumbai' => {'Nagpur' => {}}, 'Kolkata' => {})
    end
  end
end
