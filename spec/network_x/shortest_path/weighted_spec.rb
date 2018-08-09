require 'spec_helper'

RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new(type: 'undirected') }

  before do
    graph.add_nodes(%w[A B])
    graph.add_edge('A', 'B', weight: 5)
    graph.add_weighted_edges([%w[A C], %w[C D]], [2, 3])
    graph.add_node('E')
  end

  context 'when multisource_dijkstra is called' do
    subject { NetworkX.multisource_dijkstra(graph, %w[B A], 'D') }

    it do
      is_expected.to eq([5, %w[A C D]])
    end
  end

  context 'when multisource_dijkstra_path_length is called' do
    subject { NetworkX.multisource_dijkstra_path_length(graph, %w[B A]) }

    it do
      is_expected.to eq('B'=>0, 'A'=>0, 'C'=>2, 'D'=>5)
    end
  end

  context 'when multisource_dijkstra_path is called' do
    subject { NetworkX.multisource_dijkstra_path(graph, %w[B A]) }

    it do
      is_expected.to eq('B'=>['B'], 'A'=>['A'], 'C'=>%w[A C], 'D'=>%w[A C D])
    end
  end

  context 'when multisource_dijkstra_path is called' do
    subject { NetworkX.multisource_dijkstra_path(graph, %w[B A]) }

    it do
      is_expected.to eq('B'=>['B'], 'A'=>['A'], 'C'=>%w[A C], 'D'=>%w[A C D])
    end
  end

  context 'when dijkstra_predecessor_distance is called' do
    subject { NetworkX.dijkstra_predecessor_distance(graph, 'A') }

    it do
      is_expected.to eq([{'A'=>[], 'B'=>['A'], 'C'=>['A'], 'D'=>['C']}, {'A'=>0, 'C'=>2, 'B'=>5, 'D'=>5}])
    end
  end

  context 'when self.all_pairs_dijkstra is called' do
    subject { NetworkX.all_pairs_dijkstra(graph) }

    it do
      is_expected.to eq([['A',
                          [{'A'=>0, 'C'=>2, 'B'=>5, 'D'=>5},
                           {'A'=>['A'],
                            'B'=>%w[A B],
                            'C'=>%w[A C],
                            'D'=>%w[A C D]}]],
                         ['B',
                          [{'B'=>0, 'A'=>5, 'C'=>7, 'D'=>10},
                           {'B'=>['B'],
                            'A'=>%w[B A],
                            'C'=>%w[B A C],
                            'D'=>%w[B A C D]}]],
                         ['C',
                          [{'C'=>0, 'A'=>2, 'D'=>3, 'B'=>7},
                           {'C'=>['C'],
                            'A'=>%w[C A],
                            'D'=>%w[C D],
                            'B'=>%w[C A B]}]],
                         ['D',
                          [{'D'=>0, 'C'=>3, 'A'=>5, 'B'=>10},
                           {'D'=>['D'],
                            'C'=>%w[D C],
                            'A'=>%w[D C A],
                            'B'=>%w[D C A B]}]],
                         ['E', [{'E'=>0}, {'E'=>['E']}]]])
    end
  end

  context 'when dijkstra_predecessor_distance is called' do
    subject { NetworkX.dijkstra_predecessor_distance(graph, 'A') }

    it do
      is_expected.to eq([{'A'=>[], 'B'=>['A'], 'C'=>['A'], 'D'=>['C']}, {'A'=>0, 'C'=>2, 'B'=>5, 'D'=>5}])
    end
  end

  context 'when bellmanford_predecesor_distance is called' do
    subject { NetworkX.bellmanford_predecesor_distance(graph, 'A') }

    it do
      is_expected.to eq([{'A'=>[], 'B'=>['A'], 'C'=>['A'], 'D'=>['C']}, {'A'=>0, 'C'=>2, 'B'=>5, 'D'=>5}])
    end
  end

  context 'when singlesource_bellmanford is called' do
    subject { NetworkX.singlesource_bellmanford(graph, 'A') }

    it do
      is_expected.to eq([{'A'=>0, 'B'=>5, 'C'=>2, 'D'=>5}, {'A'=>['A'], 'B'=>%w[B A], 'C'=>%w[C A], 'D'=>%w[D C A]}])
    end
  end

  context 'when bellmanford_path_length is called' do
    subject { NetworkX.bellmanford_path_length(graph, 'A', 'D') }

    it do
      is_expected.to eq(5)
    end
  end

  context 'when bellmanford_path_length is called' do
    subject { NetworkX.bellmanford_path_length(graph, 'A', 'D') }

    it do
      is_expected.to eq(5)
    end
  end

  context 'when johnson is called' do
    subject { NetworkX.johnson(graph) }

    it do is_expected.to eq([['A', {'A'=>['A'], 'B'=>['A', 'B'], 'C'=>['A', 'C'], 'D'=>['A', 'C', 'D']}],
                            ['B', {'B'=>['B'], 'A'=>['B', 'A'], 'C'=>['B', 'A', 'C'], 'D'=>['B', 'A', 'C', 'D']}],
                            ['C', {'C'=>['C'], 'A'=>['C', 'A'], 'D'=>['C', 'D'], 'B'=>['C', 'A', 'B']}],
                            ['D', {'D'=>['D'], 'C'=>['D', 'C'], 'A'=>['D', 'C', 'A'], 'B'=>['D', 'C', 'A', 'B']}],
                            ['E', {'E'=>['E']}]])
    end
  end
end
