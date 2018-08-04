require 'spec_helper'

RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new(type: 'undirected') }

  before do
    graph.add_nodes(%w[A B])
    graph.add_edge('A', 'B', weight: 1)
    graph.add_weighted_edges([%w[A C], %w[C D]], [5, 1])
    graph.add_node('E')
  end

  context 'when floyd_warshall is called' do
    subject { NetworkX.floyd_warshall(graph) }

    it do
      inf = Float::INFINITY
      is_expected.to eq('A'=>{'A'=>0.0, 'B'=>1.0, 'C'=>5.0, 'D'=>6.0, 'E'=>inf},
                        'B'=>{'A'=>1.0, 'B'=>0.0, 'C'=>6.0, 'D'=>7.0, 'E'=>inf},
                        'C'=>{'A'=>5.0, 'B'=>6.0, 'C'=>0.0, 'D'=>1.0, 'E'=>inf},
                        'D'=>{'A'=>6.0, 'B'=>7.0, 'C'=>1.0, 'D'=>0.0, 'E'=>inf},
                        'E'=>{'A'=>inf, 'B'=>inf, 'C'=>inf, 'D'=>inf, 'E'=>0.0})
    end
  end
end
