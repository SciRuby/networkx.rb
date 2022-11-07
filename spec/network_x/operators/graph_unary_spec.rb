RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph_1) { described_class.new(type: 'undirected') }
  let(:graph_2) { described_class.new(type: 'undirected') }

  before do
    graph_1.add_edge(1, 2)
    graph_1.add_edge(5, 6)
  end

  context 'when union is called' do
    subject { NetworkX.complement(graph_1) }

    its('adj') do
      is_expected.to eq(1=>{5=>{}, 6=>{}},
                        2=>{5=>{}, 6=>{}},
                        5=>{1=>{}, 2=>{}},
                        6=>{1=>{}, 2=>{}})
    end
  end
end
