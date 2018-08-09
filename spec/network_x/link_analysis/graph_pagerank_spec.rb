require 'spec_helper'

RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
  end

  context 'when pagerank is called' do
    subject { NetworkX.pagerank(graph, 1 => 0.333, 2 => 0.333, 4 => 0.333) }

    it { is_expected.to eq([0.2567466855604044, 0.4865064976468385, 0.2567466855604044]) }
  end
end
