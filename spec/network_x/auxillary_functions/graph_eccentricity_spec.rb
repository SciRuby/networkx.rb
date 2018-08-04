require 'spec_helper'

RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
  end

  context 'when eccentricity is called' do
    subject { NetworkX.eccentricity(graph, 1) }

    it { is_expected.to eq(2) }
  end

  context 'when diameter is called' do
    subject { NetworkX.diameter(graph) }

    it { is_expected.to eq(2) }
  end

  context 'when radius is called' do
    subject { NetworkX.radius(graph) }

    it { is_expected.to eq(1) }
  end
end
