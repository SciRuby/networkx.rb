RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
    graph.add_edge(4, 1)
    graph.add_edge(1, 3)
    graph.add_edge(3, 10)
    graph.add_edge(1, 10)
    graph.add_edge(5, 6)
    graph.add_edge(6, 7)
    graph.add_edge(7, 5)
  end

  context 'when cycle_basis is called' do
    subject { NetworkX.cycle_basis(graph, 1) }

    it { is_expected.to eq([[4, 2, 1], [10, 3, 1], [7, 6, 5]]) }
  end

  context 'when find_cycle is called' do
    subject { NetworkX.find_cycle(graph, 1) }

    it { is_expected.to eq([[1, 2], [2, 4], [4, 1]]) }
  end

  it 'when find_cycle occures ArgumentError' do
    empty_graph = NetworkX::Graph.empty_graph(3)
    expect{NetworkX.find_cycle(empty_graph, 0)}.to raise_error(ArgumentError)

    null_graph = NetworkX::Graph.null_graph
    expect{NetworkX.find_cycle(null_graph, 0)}.to raise_error(ArgumentError)

    tree = NetworkX::Graph.balanced_tree(3, 2)
    expect{NetworkX.find_cycle(tree, 0)}.to raise_error(ArgumentError)
  end

  it 'cycle? only for Undirected Graph' do
    undirected_graph = NetworkX::Graph.new
    expect(NetworkX.cycle?(undirected_graph)).to be false

    undirected_graph.add_edge(0, 1)
    expect(NetworkX.cycle?(undirected_graph)).to be false

    undirected_graph.add_edge(1, 2)
    expect(NetworkX.cycle?(undirected_graph)).to be false

    undirected_graph.add_edge(2, 0)
    expect(NetworkX.cycle?(undirected_graph)).to be_truthy
  end
end
