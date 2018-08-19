RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
  end

  context 'when hits is called' do
    subject { NetworkX.hits(graph, 1 => 0.333, 2 => 0.333, 4 => 0.333) }

    it { is_expected.to eq([{1=>1.0, 2=>1.0, 4=>1.0}, {1=>0.5, 2=>1.0, 4=>0.5}]) }
  end

  context 'when authority_matrix is called' do
    subject { NetworkX.authority_matrix(graph) }

    it { is_expected.to eq(NMatrix[[1, 0, 1], [0, 2, 0], [1, 0, 1]]) }
  end

  context 'when hub_matrix is called' do
    subject { NetworkX.hub_matrix(graph) }

    it { is_expected.to eq(NMatrix[[1, 0, 1], [0, 2, 0], [1, 0, 1]]) }
  end
end
