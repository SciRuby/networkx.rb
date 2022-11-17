RSpec.describe NetworkX::DiGraph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
  end

  context 'when capacity_scaling is called' do
    subject { NetworkX.capacity_scaling(graph) }

    it { is_expected.to eq([0, {1 => {2 => 0}, 2 => {4 => 0}, 4 => {}}]) }
  end

  it 'negative_edge_cycle when Argument Error in this method' do
    graph = NetworkX::Graph.new
    graph.add_weighted_edges([[:a, :b], [:b, :a]], [9, -10])

    expect(NetworkX.negative_edge_cycle(graph)).to be_truthy
  end
end
