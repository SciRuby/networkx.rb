RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
    graph.add_edge(1, 4)
    graph.add_edge(5, 6)
    graph.add_edge(7, 6)
    graph.add_edge(5, 7)
  end

  context 'when cliques is called' do
    subject { NetworkX.find_cliques(graph) }

    it { is_expected.to eq([[7, 5, 6], [1, 2, 4]]) }
  end
end
