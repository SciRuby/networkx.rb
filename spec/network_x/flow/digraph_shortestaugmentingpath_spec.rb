RSpec.describe NetworkX::DiGraph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2, capacity: 1)
    graph.add_edge(2, 4, capacity: 1)
  end

  context 'when shortest_augmenting_path is called' do
    subject { NetworkX.shortest_augmenting_path(graph, 1, 4) }

    its('adj') do
      is_expected.to eq(1 => {2 => {capacity: 1, flow: 1}},
                        2 => {1 => {capacity: 0, flow: -1},
                              4 => {capacity: 1, flow: 1}},
                        4 => {2 => {capacity: 0, flow: -1}})
    end
  end

  it 'shortest_augmenting_path for DiGraph with no capacity' do
    graph = NetworkX::DiGraph.new
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
    expect{ NetworkX.shortest_augmenting_path(graph, 1, 4) }.to raise_error(ArgumentError)
  end
end
