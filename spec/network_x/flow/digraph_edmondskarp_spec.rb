RSpec.describe NetworkX::DiGraph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
  end

  context 'when edmondskarp is called' do
    subject { NetworkX.edmondskarp(graph, 1, 4) }

    its('adj') do
      is_expected.to eq(1=>{2=>{capacity: 1, flow: 0}},
                        2=>{1=>{capacity: 0, flow: 0},
                            4=>{capacity: 1, flow: 0}},
                        4=>{2=>{capacity: 0, flow: 0}})
    end
  end
end
