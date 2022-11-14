RSpec.describe NetworkX::DiGraph do
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
      is_expected.to eq('Nagpur' => {'Mumbai' => {}, 'Chennai' => {}},
                        'Bangalore' => {},
                        'Chennai' => {'Bangalore' => {}},
                        'Mumbai' => {}, 'Kolkata' => {})
    end

    its('pred') do
      is_expected.to eq('Nagpur' => {},
                        'Bangalore' => {'Chennai' => {}},
                        'Chennai' => {'Nagpur' => {}},
                        'Mumbai' => {'Nagpur' => {}}, 'Kolkata' => {})
    end
  end

  it 'node' do
    graph = NetworkX::DiGraph.new
    graph.add_edges([[1, 2], [5, 6]])
    graph.add_node(10, name: 'ten')
    expect(graph.nodes(data: false).sort).to eq([1, 2, 5, 6, 10])
    expect(graph.nodes(data: true)).to eq({1 => {}, 2 => {}, 5 => {}, 6 => {}, 10 => {name: 'ten'}})
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

  it 'tests DiGraph#clear' do
    graph = NetworkX::DiGraph.new(name: 'test')
    graph.add_edge(:x, :y, key: 'first')
    graph.add_edge(:x, :y, key: 'second')
    graph.clear
    expect(graph.number_of_edges).to be 0
    expect(graph.number_of_nodes).to be 0
    expect(graph.graph).to eq({})
    expect(graph.adj).to eq({})
  end

  context 'when weighted edge/s is/are added' do
    before do
      graph.add_weighted_edge('Nagpur', 'Mumbai', 15)
      graph.add_weighted_edges([%w[Nagpur Kolkata]], [10])
    end

    its('adj') do
      is_expected.to eq('Bangalore' => {},
                        'Chennai' => {'Bangalore' => {}},
                        'Kolkata' => {},
                        'Mumbai' => {},
                        'Nagpur' => {'Mumbai' => {weight: 15}, 'Chennai' => {}, 'Kolkata' => {weight: 10}})
    end
  end

  context 'when number of edges are calculated' do
    its('number_of_edges') do
      is_expected.to eq 3
    end
  end

  it 'test number_of_edges of empty graph returns 0' do
    empty_graph = NetworkX::DiGraph.new
    expect(empty_graph.number_of_edges).to be 0
  end

  it 'test indegree & out_degree of MultiDiGraph with no edge' do
    graph = NetworkX::DiGraph.new
    graph.add_node(0)
    graph.add_node(1)

    expect(graph.in_degree(0)).to be 0
    expect(graph.in_degree(1)).to be 0
    expect(graph.out_degree(0)).to be 0
    expect(graph.out_degree(1)).to be 0
  end

  it 'test indegree & out_degree of simple MultiDiGraph' do
    graph = NetworkX::DiGraph.new
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
    graph = NetworkX::DiGraph.new
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
      is_expected.to eq('Nagpur' => {'Mumbai' => {}}, 'Mumbai' => {})
    end
  end

  it 'test `subgraph` method' do
    g = NetworkX::DiGraph.new
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
      is_expected.to eq('Nagpur' => {'Chennai' => {}, 'Mumbai' => {}}, 'Mumbai' => {}, 'Chennai' => {})
    end
  end

  it 'tests error of subgraph & edge_subgraph' do
    g = NetworkX::DiGraph.new
    expect { g.subgraph(nil) }.to raise_error(ArgumentError)
    expect { g.edge_subgraph(nil) }.to raise_error(ArgumentError)
  end

  context 'when reverse is called' do
    subject { graph.reverse }

    its('adj') do
      is_expected.to eq('Nagpur' => {},
                        'Bangalore' => {'Chennai' => {}},
                        'Chennai' => {'Nagpur' => {}},
                        'Mumbai' => {'Nagpur' => {}}, 'Kolkata' => {})
    end
  end
end
