RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
  end

  context 'when pagerank is called' do
    subject { NetworkX.pagerank(graph, 1 => 0.333, 2 => 0.333, 4 => 0.333) }

    it { is_expected.to eq([0.2567467074324632, 0.4865065851350735, 0.2567467074324632]) }
  end
end
