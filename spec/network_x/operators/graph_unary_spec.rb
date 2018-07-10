require 'spec_helper'

RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph1) { described_class.new(type: 'undirected') }
  let(:graph2) { described_class.new(type: 'undirected') }

  before do
    graph1.add_edge(1, 2)
    graph1.add_edge(5, 6)
  end

  context 'when union is called' do
    subject { NetworkX.complement(graph1) }

    its('adj') do
      is_expected.to eq(1=>{5=>{}, 6=>{}},
                        2=>{5=>{}, 6=>{}},
                        5=>{1=>{}, 2=>{}},
                        6=>{1=>{}, 2=>{}})
    end
  end
end
