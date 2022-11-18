RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph1) { described_class.new(type: 'undirected') }
  let(:graph2) { described_class.new(type: 'undirected') }

  before do
    graph1.add_edge(1, 2)
    graph2.add_edge(5, 6)
  end

  context 'when tensor_product is called' do
    subject { NetworkX.tensor_product(graph1, graph2) }

    its('adj') do
      is_expected.to eq([1, 5] => {[2, 6] => {}},
                        [1, 6] => {[2, 5] => {}},
                        [2, 5] => {[1, 6] => {}},
                        [2, 6] => {[1, 5] => {}})
    end
  end

  context 'when lexicographic_product is called' do
    subject { NetworkX.lexicographic_product(graph1, graph2) }

    its('adj') do
      is_expected.to eq([1, 5] => {[2, 5] => {}, [2, 6] => {}, [1, 6] => {}},
                        [1, 6] => {[2, 5] => {}, [2, 6] => {}, [1, 5] => {}},
                        [2, 5] => {[1, 5] => {}, [1, 6] => {}, [2, 6] => {}},
                        [2, 6] => {[1, 5] => {}, [1, 6] => {}, [2, 5] => {}})
    end
  end

  context 'when cartesian_product is called' do
    subject { NetworkX.cartesian_product(graph1, graph2) }

    its('adj') do
      is_expected.to eq([1, 5] => {[2, 5] => {}, [1, 6] => {}},
                        [1, 6] => {[2, 6] => {}, [1, 5] => {}},
                        [2, 5] => {[1, 5] => {}, [2, 6] => {}},
                        [2, 6] => {[1, 6] => {}, [2, 5] => {}})
    end
  end

  context 'when strong_product is called' do
    subject { NetworkX.strong_product(graph1, graph2) }

    its('adj') do
      is_expected.to eq([1, 5] => {[1, 6] => {}, [2, 5] => {}, [2, 6] => {}},
                        [1, 6] => {[1, 5] => {}, [2, 6] => {}, [2, 5] => {}},
                        [2, 5] => {[2, 6] => {}, [1, 5] => {}, [1, 6] => {}},
                        [2, 6] => {[2, 5] => {}, [1, 6] => {}, [1, 5] => {}})
    end
  end

  context 'when power is called' do
    subject { NetworkX.power(graph1, 2) }

    its('adj') { is_expected.to eq(1 => {2 => {}}, 2 => {1 => {}}) }
  end

  it 'edges_in_array' do
    graph = NetworkX::MultiDiGraph.new
    expect(NetworkX.edges_in_array(graph)).to eq []

    graph.add_nodes_from([:a, :b])
    expect(NetworkX.edges_in_array(graph)).to eq []

    graph.add_edge(:a, :b)
    expect(NetworkX.edges_in_array(graph)).to eq [[:a, :b, {}]]

    graph.add_edge(:a, :b)
    expect(NetworkX.edges_in_array(graph)).to eq [[:a, :b, {}], [:a, :b, {}]]
  end
end
