RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph1) { described_class.new(type: 'undirected') }
  let(:graph2) { described_class.new(type: 'undirected') }

  before do
    graph1.add_edge(1, 2)
    graph2.add_edge(5, 6)
  end

  context 'when union is called' do
    subject { NetworkX.union(graph1, graph2) }

    its('adj') do
      is_expected.to eq(1 => {2 => {}},
                        2 => {1 => {}},
                        5 => {6 => {}},
                        6 => {5 => {}})
    end
  end

  context 'when disjoint_union is called' do
    subject { NetworkX.disjoint_union(graph1, graph2) }

    its('adj') do
      is_expected.to eq('10' => {'21' => {}},
                        '21' => {'10' => {}},
                        '50' => {'61' => {}},
                        '61' => {'50' => {}})
    end
  end

  context 'when compose is called' do
    subject { NetworkX.compose(graph1, graph2) }

    its('adj') do
      is_expected.to eq(1 => {2 => {}},
                        2 => {1 => {}},
                        5 => {6 => {}},
                        6 => {5 => {}})
    end
  end

  context 'when symmetric_difference is called' do
    subject { NetworkX.symmetric_difference(graph1, graph2) }

    before do
      graph2.clear
      graph2.add_node(1)
      graph2.add_node(2)
    end

    its('adj') { is_expected.to eq(1 => {2 => {}}, 2 => {1 => {}}) }
  end

  context 'when difference is called' do
    subject { NetworkX.difference(graph1, graph2) }

    before do
      graph2.clear
      graph2.add_node(1)
      graph2.add_node(2)
    end

    its('adj') { is_expected.to eq(1 => {2 => {}}, 2 => {1 => {}}) }
  end

  context 'when intersection is called' do
    subject { NetworkX.intersection(graph1, graph1) }

    its('adj') { is_expected.to eq(1 => {2 => {}}, 2 => {1 => {}}) }
  end
end
