RSpec.describe NetworkX::DiGraph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2, capacity: 1)
    graph.add_edge(2, 4, capacity: 1)
  end

  context 'when edmondskarp is called' do
    subject { NetworkX.edmondskarp(graph, 1, 4) }

    its('adj') do
      is_expected.to eq(1 => {2 => {capacity: 1, flow: 1}},
                        2 => {1 => {capacity: 0, flow: -1},
                              4 => {capacity: 1, flow: 1}},
                        4 => {2 => {capacity: 0, flow: -1}})
    end
  end

  it 'when edmondskarp is called for DiGraph with no capacity' do
    graph = NetworkX::DiGraph.new
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
    expect{ NetworkX.edmondskarp(graph, 1, 4) }.to raise_error(ArgumentError)
  end

  it 'when edmondskarp is called for simple DiGraph' do
    graph = NetworkX::DiGraph.new
    graph.add_edge(1, 2, capacity: 1)
    graph.add_edge(2, 4, capacity: 1)
    r = NetworkX.edmondskarp(graph, 1, 4)
    expect(r.graph[:flow_value]).to be 1
  end

  it 'edmond_carp' do
    g = NetworkX::DiGraph.new
    g.add_edge('x', 'a', capacity: 3.0)
    g.add_edge('x', 'b', capacity: 1.0)
    g.add_edge('a', 'c', capacity: 3.0)
    g.add_edge('b', 'c', capacity: 5.0)
    g.add_edge('b', 'd', capacity: 4.0)
    g.add_edge('d', 'e', capacity: 2.0)
    g.add_edge('c', 'y', capacity: 2.0)
    g.add_edge('e', 'y', capacity: 3.0)
    r = NetworkX.edmondskarp(g, 'x', 'y')
    expect(r.graph[:flow_value]).to be 3.0
  end
end
