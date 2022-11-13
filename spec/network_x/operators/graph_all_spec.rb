RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph1) { [] }
  let(:graph2) { [] }

  before do
    graph1 << described_class.new
    graph1 << described_class.new
    graph1[0].add_edge(1, 2)
    graph1[1].add_edge(3, 4)

    graph2 << described_class.new
    graph2 << described_class.new
    graph2[0].add_edge(1, 2)
    graph2[1].add_node(1)
    graph2[1].add_node(2)
  end

  context 'when union_all is called' do
    subject { NetworkX.union_all(graph1) }

    its('adj') { is_expected.to eq(1 => {2 => {}}, 2 => {1 => {}}, 3 => {4 => {}}, 4 => {3 => {}}) }
  end

  context 'when disjoint_union_all is called' do
    subject { NetworkX.disjoint_union_all(graph1) }

    its('adj') do
      is_expected.to eq('10' => {'21' => {}},
                        '21' => {'10' => {}},
                        '30' => {'41' => {}},
                        '41' => {'30' => {}})
    end
  end

  context 'when intersection_all is called' do
    subject { NetworkX.intersection_all(graph2) }

    its('adj') { is_expected.to eq(1 => {}, 2 => {}) }
  end

  context 'when compose_all is called' do
    subject { NetworkX.compose_all(graph1) }

    its('adj') { is_expected.to eq(1 => {2 => {}}, 2 => {1 => {}}, 3 => {4 => {}}, 4 => {3 => {}}) }
  end
end
