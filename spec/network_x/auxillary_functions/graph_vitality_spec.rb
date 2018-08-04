require 'spec_helper'

RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
    graph.add_edge(1, 4)
    graph.add_edge(5, 2)
  end

  context 'when vitality is called' do
    subject { NetworkX.closeness_vitality(graph, 1) }

    it { is_expected.to eq(4) }
  end
end
