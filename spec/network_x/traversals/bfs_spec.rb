require 'spec_helper'

RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new(type: 'undirected') }

  before do
    graph.add_nodes(%w[A B])
    graph.add_edge('A', 'B')
    graph.add_edges([%w[A C], %w[C D]])
    graph.add_node('E')
  end

  context 'when bfs_edges is called' do
    subject { NetworkX.bfs_edges(graph, 'A') }

    it do
      is_expected.to eq([%w[A B], %w[A C], %w[C D]])
    end
  end

  context 'when bfs_successors is called' do
    subject { NetworkX.bfs_successors(graph, 'A') }

    it do
      is_expected.to eq('A' => %w[B C], 'C' => ['D'])
    end
  end

  context 'when bfs_predecessors is called' do
    subject { NetworkX.bfs_predecessors(graph, 'A') }

    it do
      is_expected.to eq('B' => 'A', 'C' => 'A', 'D' => 'C')
    end
  end
end
