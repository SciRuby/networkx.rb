require 'spec_helper'

RSpec.describe NetworkX::DiGraph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
  end

  context 'when shortest_augmenting_path is called' do
    subject { NetworkX.shortest_augmenting_path(graph, 1, 4) }

    its('adj') { is_expected.to eq({1=>{2=>{:capacity=>1, :flow=>0}},
                                    2=>{1=>{:capacity=>0, :flow=>0},
                                    4=>{:capacity=>1, :flow=>0}},
                                    4=>{2=>{:capacity=>0, :flow=>0}}}) }
  end
end
