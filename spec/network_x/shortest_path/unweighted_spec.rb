RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new(type: 'undirected') }

  before do
    graph.add_nodes(%w[A B])
    graph.add_edge('A', 'B')
    graph.add_edges([%w[A C], %w[C D]])
    graph.add_node('E')
  end

  context 'when single_source_shortest_path_length is called' do
    subject { NetworkX.single_source_shortest_path_length(graph, 'A') }

    it do
      is_expected.to eq([['A', 0], ['B', 1], ['C', 1], ['D', 2]])
    end
  end

  context 'when all_pairs_shortest_path_length is called' do
    subject { NetworkX.all_pairs_shortest_path_length(graph) }

    it do
      is_expected.to eq([['A', [['A', 0], ['B', 1], ['C', 1], ['D', 2]]],
                         ['B', [['B', 0], ['A', 1], ['C', 2], ['D', 3]]],
                         ['C', [['C', 0], ['A', 1], ['D', 1], ['B', 2]]],
                         ['D', [['D', 0], ['C', 1], ['A', 2], ['B', 3]]],
                         ['E', [['E', 0]]]])
    end
  end

  context 'when single_source_shortest_path is called' do
    subject { NetworkX.single_source_shortest_path(graph, 'A') }

    it do
      is_expected.to eq('A' => ['A'], 'B' => %w[A B], 'C' => %w[A C], 'D' => %w[A C D])
    end
  end

  context 'when all_pairs_shortest_path is called' do
    subject { NetworkX.all_pairs_shortest_path(graph) }

    it do
      is_expected.to eq([['A', {'A' => ['A'], 'B' => %w[A B], 'C' => %w[A C], 'D' => %w[A C D]}],
                         ['B', {'B' => ['B'], 'A' => %w[B A], 'C' => %w[B A C], 'D' => %w[B A C D]}],
                         ['C', {'C' => ['C'], 'A' => %w[C A], 'D' => %w[C D], 'B' => %w[C A B]}],
                         ['D', {'D' => ['D'], 'C' => %w[D C], 'A' => %w[D C A], 'B' => %w[D C A B]}],
                         ['E', {'E' => ['E']}]])
    end
  end

  context 'when predecessor is called' do
    subject { NetworkX.predecessor(graph, 'A', true) }

    it do
      is_expected.to eq('A' => [], 'B' => ['A'], 'C' => ['A'], 'D' => ['C'])
    end
  end
end
