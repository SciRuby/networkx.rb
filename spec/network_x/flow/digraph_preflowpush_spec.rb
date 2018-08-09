require 'spec_helper'

RSpec.describe NetworkX::DiGraph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2, capacity: 1)
    graph.add_edge(2, 4, capacity: 3)
  end

  context 'when preflowpush is called' do
    subject { NetworkX.preflowpush(graph, 1, 4) }

    its('adj') { is_expected.to eq({1=>{2=>{:capacity=>1, :flow=>1}},
                                    2=>{1=>{:capacity=>0, :flow=>-1}, 4=>{:capacity=>3, :flow=>1}},
                                    4=>{2=>{:capacity=>0, :flow=>-1}}}) }
  end
end
