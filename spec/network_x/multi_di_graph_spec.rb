RSpec.describe NetworkX::MultiDiGraph do
  subject { graph }

  let(:graph) { described_class.new(name: 'Cities', type: 'directed') }

  before do
    graph.add_nodes(%w[Nagpur Mumbai])
    graph.add_edge('Nagpur', 'Mumbai')
    graph.add_edges([%w[Nagpur Chennai], %w[Chennai Bangalore]])
    graph.add_node('Kolkata')
  end

  context 'when graph has been assigned attributes' do
    its('graph') { is_expected.to eq(name: 'Cities', type: 'directed') }
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
                        'Bangalore' => {},
                        'Chennai' => {'Bangalore' => {0 => {}}},
                        'Mumbai' => {}, 'Kolkata' => {})
    end

    its('pred') do
      is_expected.to eq('Nagpur' => {},
                        'Bangalore' => {'Chennai' => {0 => {}}},
                        'Chennai' => {'Nagpur' => {0 => {}}},
                        'Mumbai' => {'Nagpur' => {0 => {}}}, 'Kolkata' => {})
    end
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

  it 'test remove_edge' do
    graph = NetworkX::MultiDiGraph.new
    graph.add_edge(:s, :t, key: 'first')
    graph.add_edge(:s, :t, key: 'second')
    graph.add_edge(:s, :t, key: 'third')
    expect(graph.number_of_edges).to be 3

    graph.remove_edge(:s, :t, 'second')
    expect(graph.number_of_edges).to be 2

    expect { graph.remove_edge(:s, :t, '1st') }.to raise_error(KeyError)
  end

  context 'when weighted edge/s is/are added' do
    before do
      graph.remove_nodes(%w[Chennai Bangalore])
      graph.add_weighted_edge('Nagpur', 'Mumbai', 15)
      graph.add_weighted_edges([%w[Nagpur Kolkata]], [10])
    end

    its('adj') do
      is_expected.to eq('Kolkata' => {},
                        'Mumbai' => {},
                        'Nagpur' => {'Mumbai' => {0 => {}, 1 => {weight: 15}},
                                     'Kolkata' => {0 => {weight: 10}}})
    end
  end

  context 'when number of edges are calculated' do
    its('number_of_edges') do
      is_expected.to eq 3
    end
  end

  it 'test number_of_edges of empty graph returns 0' do
    empty_graph = NetworkX::MultiDiGraph.new
    expect(empty_graph.number_of_edges).to be 0
  end

  it 'test indegree & out_degree of MultiDiGraph with no edge' do
    graph = NetworkX::MultiDiGraph.new
    graph.add_node(0)
    graph.add_node(1)

    expect(graph.in_degree(0)).to be 0
    expect(graph.in_degree(1)).to be 0
    expect(graph.out_degree(0)).to be 0
    expect(graph.out_degree(1)).to be 0
  end

  it 'test indegree & out_degree of simple MultiDiGraph' do
    graph = NetworkX::MultiDiGraph.new
    graph.add_edges([[0, 1], [1, 2], [2, 3], [3, 4]])

    expect(graph.in_degree(0)).to be 0
    expect(graph.in_degree(1)).to be 1
    expect(graph.in_degree(2)).to be 1
    expect(graph.in_degree(3)).to be 1
    expect(graph.in_degree(4)).to be 1

    expect(graph.out_degree(0)).to be 1
    expect(graph.out_degree(1)).to be 1
    expect(graph.out_degree(2)).to be 1
    expect(graph.out_degree(3)).to be 1
    expect(graph.out_degree(4)).to be 0
  end

  it 'tests edge?' do
    graph = NetworkX::MultiDiGraph.new
    expect(graph.has_edge?(:x, :y)).to be_falsy

    graph.add_edge(:x, :y)
    expect(graph.has_edge?(:x, :y)).to be_truthy
  end

  it 'tests edge? with key' do
    graph = NetworkX::MultiDiGraph.new
    expect(graph.has_edge?(:x, :y, 'first')).to be_falsy

    graph.add_edge(:x, :y, key: 'first')
    expect(graph.has_edge?(:x, :y, 'first')).to be_truthy
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
    graph = NetworkX::MultiDiGraph.new
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
      is_expected.to eq('Nagpur' => {'Mumbai' => {0 => {}}}, 'Mumbai' => {})
    end
  end

  it 'test `subgraph` method' do
    g = NetworkX::MultiDiGraph.new
    g.add_nodes_from(0...4)
    g.add_edges([[0, 1], [1, 2], [1, 3]])

    h = g.subgraph([0, 1, 2])

    expect(h.number_of_nodes).to eq 3
    expect(h.edges).to eq [[0, 1], [1, 2]]
  end

  context 'when edges_subgraph is called' do
    subject { graph.edge_subgraph([%w[Nagpur Mumbai], %w[Nagpur Chennai]]) }

    its('nodes') do
      is_expected.to eq('Nagpur' => {}, 'Mumbai' => {}, 'Chennai' => {})
    end

    its('adj') do
      is_expected.to eq('Nagpur' => {'Chennai' => {0 => {}}, 'Mumbai' => {0 => {}}}, 'Mumbai' => {}, 'Chennai' => {})
    end
  end

  it 'tests error from subgraph and edge_subgraph' do
    g = NetworkX::MultiDiGraph.new
    expect { g.subgraph(nil) }.to raise_error(ArgumentError)
    expect { g.edge_subgraph(nil) }.to raise_error(ArgumentError)
  end

  it 'nodes' do
    graph = NetworkX::MultiDiGraph.new
    graph.add_edges([[:x, :y], [:y, :z]])
    expect(graph.nodes(data: false)).to eq([:x, :y, :z])
    expect(graph.nodes(data: true)).to eq({x: {}, y: {}, z: {}})
  end

  context 'when reverse is called' do
    subject { graph.reverse }

    its('adj') do
      is_expected.to eq('Nagpur' => {},
                        'Bangalore' => {'Chennai' => {0 => {}}},
                        'Chennai' => {'Nagpur' => {0 => {}}},
                        'Mumbai' => {'Nagpur' => {0 => {}}}, 'Kolkata' => {})
    end
  end

  it 'to_undirected' do
    multi_directed_graph = NetworkX::MultiDiGraph.new(name: 'MultiDi')
    multi_directed_graph.add_edges([[:a, :b], [:c, :d]])

    undirected_graph = multi_directed_graph.to_undirected
    expect(undirected_graph.class).to eq NetworkX::Graph
    expect(undirected_graph.graph[:name]).to eq 'MultiDi'
    expect(undirected_graph.number_of_edges).to be 2
    expect(undirected_graph.number_of_nodes).to be 4
  end

  it 'to_directed' do
    multi_directed_graph = NetworkX::MultiDiGraph.new(name: 'MultiDi')
    multi_directed_graph.add_edges([[:a, :b], [:a, :b]])
    expect(multi_directed_graph.number_of_edges).to be 2
    expect(multi_directed_graph.number_of_nodes).to be 2

    undirected_graph = multi_directed_graph.to_directed
    expect(undirected_graph.class).to eq NetworkX::DiGraph
    expect(undirected_graph.graph[:name]).to eq 'MultiDi'
    expect(undirected_graph.number_of_edges).to be 1
    expect(undirected_graph.number_of_nodes).to be 2
  end
end
