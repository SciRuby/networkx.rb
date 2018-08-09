require 'spec_helper'

RSpec.describe NetworkX::Graph do
  subject { graph }

  let(:graph) { described_class.new }

  before do
    graph.add_edge(1, 2)
    graph.add_edge(2, 4)
    graph.add_edge(1, 4)
    graph.add_edge(5, 2)
  end

  context 'when mst is called' do
    subject { NetworkX.minimum_spanning_tree(graph) }

    its('adj') { is_expected.to eq(1=>{2=>{}, 4=>{}}, 2=>{1=>{}, 5=>{}}, 4=>{1=>{}}, 5=>{2=>{}}) }
  end
end
