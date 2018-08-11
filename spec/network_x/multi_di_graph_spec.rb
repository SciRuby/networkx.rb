RSpec.describe NetworkX::MultiDiGraph do
  subject { graph }

  let(:graph) { described_class.new(name: 'Cities', type: 'directed') }

  before do
    graph.add_nodes(%w[Nagpur Mumbai])
    graph.add_edge('Nagpur', 'Mumbai')
    graph.add_edges([%w[Nagpur Chennai], %w[Chennai Bangalore]])
    graph.add_node('Kolkata')
  end

  context 'when graph has been assigned attributes' do
    its('graph') { is_expected.to eq(name: 'Cities', type: 'directed') }
  end

  context 'when a new node/s has/have been created' do
    its('nodes') do
      is_expected.to eq('Kolkata' => {},
                        'Nagpur' => {},
                        'Mumbai' => {},
                        'Chennai' => {},
                        'Bangalore' => {})
    end
  end

  context 'when a new edge/s has/have been added' do
    its('adj') do
      is_expected.to eq('Nagpur' => {'Mumbai' => {0 => {}}, 'Chennai' => {0 => {}}},
                        'Bangalore' => {},
                        'Chennai' => {'Bangalore' => {0 => {}}},
                        'Mumbai' => {}, 'Kolkata' => {})
    end

    its('pred') do
      is_expected.to eq('Nagpur' => {},
                        'Bangalore' => {'Chennai' => {0 => {}}},
                        'Chennai' => {'Nagpur' => {0 => {}}},
                        'Mumbai' => {'Nagpur' => {0 => {}}}, 'Kolkata' => {})
    end
  end

  context 'when node/s is/are removed' do
    before do
      graph.remove_node('Nagpur')
      graph.remove_nodes(%w[Chennai Mumbai])
    end

    its('nodes') { is_expected.to eq('Kolkata' => {}, 'Bangalore'=> {}) }
    its('adj') { is_expected.to eq('Kolkata' => {}, 'Bangalore' => {}) }
  end

  context 'when edge/s is/are removed' do
    before do
      graph.remove_edge('Nagpur', 'Mumbai')
      graph.remove_edges([%w[Nagpur Chennai], %w[Chennai Bangalore]])
    end

    its('adj') do
      is_expected.to eq('Kolkata' => {}, 'Bangalore' => {},\
                        'Nagpur' => {}, 'Chennai' => {}, 'Mumbai' => {})
    end
  end

  context 'when weighted edge/s is/are added' do
    before do
      graph.remove_nodes(%w[Chennai Bangalore])
      graph.add_weighted_edge('Nagpur', 'Mumbai', 15)
      graph.add_weighted_edges([%w[Nagpur Kolkata]], [10])
    end

    its('adj') do
      is_expected.to eq('Kolkata' => {},
                        'Mumbai' => {},
                        'Nagpur' => {'Mumbai' => {0 => {}, 1 => {weight: 15}},
                                     'Kolkata' => {0 => {weight: 10}}})
    end
  end

  context 'when number of edges are calculated' do
    its('number_of_edges') do
      is_expected.to eq 3
    end
  end

  context 'when size is called' do
    subject { graph.size(true) }

    before do
      graph.add_weighted_edge('Nagpur', 'Mumbai', 15)
    end

    it do
      is_expected.to eq 15
    end
  end

  context 'when subgraph is called' do
    subject { graph.subgraph(%w[Nagpur Mumbai]) }

    its('nodes') do
      is_expected.to eq('Nagpur' => {}, 'Mumbai' => {})
    end

    its('adj') do
      is_expected.to eq('Nagpur' => {'Mumbai' => {0 => {}}}, 'Mumbai' => {})
    end
  end

  context 'when edges_subgraph is called' do
    subject { graph.edge_subgraph([%w[Nagpur Mumbai], %w[Nagpur Chennai]]) }

    its('nodes') do
      is_expected.to eq('Nagpur' => {}, 'Mumbai' => {}, 'Chennai' => {})
    end

    its('adj') do
      is_expected.to eq('Nagpur' => {'Chennai' => {0 => {}}, 'Mumbai' => {0 => {}}}, 'Mumbai' => {}, 'Chennai' => {})
    end
  end

  context 'when reverse is called' do
    subject { graph.reverse }

    its('adj') do
      is_expected.to eq('Nagpur' => {},
                        'Bangalore' => {'Chennai' => {0 => {}}},
                        'Chennai' => {'Nagpur' => {0 => {}}},
                        'Mumbai' => {'Nagpur' => {0 => {}}}, 'Kolkata' => {})
    end
  end
end
