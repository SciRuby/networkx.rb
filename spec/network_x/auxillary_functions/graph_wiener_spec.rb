RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
    graph.add_edge(1, 4)
    graph.add_edge(5, 2)
  end

  context 'when wiener_index is called' do
    subject { NetworkX.wiener_index(graph) }

    it { is_expected.to eq(8) }
  end
end
