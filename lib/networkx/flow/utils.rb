module NetworkX
  # Helper class for preflow push algorithm
  class CurrentEdge
    attr_reader :curr, :edges

    def initialize(edges)
      @edges = edges
      @index = {}
      @n = edges.length
      @curr = 0
      edges.each_with_index { |(key, _value), idx| @index[idx] = key }
    end

    def get
      [@index[@curr], @edges[@index[@curr]]]
    end

    def move_to_next
      @temp = @curr
      @curr = (@curr + 1) % @n
      raise StopIteration if @temp == @n - 1
    end
  end

  # Helper class for preflow push algorithm
  class Level
    attr_reader :inactive, :active

    def initialize
      @inactive = Set.new
      @active = Set.new
    end
  end

  # Helper class for preflow push algorithm
  class GlobalRelabelThreshold
    def initialize(n, m, freq)
      freq = freq.nil? ? Float::INFINITY : freq
      @threshold = (n + m) / freq
      @work = 0
    end

    def add_work(work)
      @work += work
    end

    def is_reached
      @work >= @threshold
    end

    def clear_work
      @work = 0
    end
  end

  # Builds a residual graph from a constituent graph
  #
  # @param graph [DiGraph] a graph
  #
  # @return [DiGraph] residual graph
  def self.build_residual_network(g)
    raise NotImplementedError, 'MultiGraph and MultiDiGraph not supported!' if g.multigraph?

    r_network = NetworkX::DiGraph.new(inf: 0, flow_value: 0)
    r_network.add_nodes(g.nodes.keys)
    inf = Float::INFINITY
    edge_list = []

    g.adj.each do |u, u_edges|
      require 'spec_helper'
      RSpec.describe NetworkX::DiGraph do
        subject { graph }

        let(:graph) { described_class.new }

        before do
          graph.add_edge(1, 2)
          graph.add_edge(2, 4)
        end

        context 'when capacity_scaling is called' do
          subject { NetworkX.capacity_scaling(graph) }

          it { is_expected.to eq([0, {1=>{2=>0}, 2=>{4=>0}, 4=>{}}]) }
        end
      end

      u_edges.each do |v, uv_attrs|
        edge_list << [u, v, uv_attrs] if (uv_attrs[:capacity] || inf) > 0 && u != v
      end
    end

    inf_chk = 3 * edge_list.inject(0) { |result, arr| arr[2].key?(:capacity) && arr[2][:capacity] != inf ? (result + arr[2][:capacity]) : result }
    inf = inf_chk == 0 ? 1 : inf_chk

    if g.directed?
      edge_list.each do |u, v, attrs|
        r = [attrs[:capacity] || inf, inf].min
        if r_network.adj[u][v].nil?
          r_network.add_edge(u, v, capacity: r)
          r_network.add_edge(v, u, capacity: 0)
        else
          r_network[u][v][:capacity] = r
        end
      end
    else
      edge_list.each do |u, v, attrs|
        r = [attrs[:capacity] || inf, inf].min
        r_network.add_edge(u, v, capacity: r)
        r_network.add_edge(v, u, capacity: r)
      end
    end
    r_network.graph[:inf] = inf
    r_network
  end

  # Detects unboundedness in a graph, raises exception when
  #   infinite capacity flow is found
  #
  # @param graph [DiGraph] a graph
  # @param residual [DiGraph] residual graph
  def self.detect_unboundedness(r_network, s, t)
    q = [s]
    seen = Set.new([s])
    inf = r_network.graph[:inf]
    until q.empty?
      u = q.shift
      r_network.adj[u].each do |v, uv_attrs|
        next unless uv_attrs[:capacity] == inf && !seen.include?(v)
        raise ArgumentError, 'Infinite capacity flow!' if v == t
        seen << v
        q << v
      end
    end
  end

  # Build flow dictionary of a graph from its residual graph
  #
  # @param graph [DiGraph] a graph
  # @param residual [DiGraph] residual graph
  #
  # @return [Hash{ Object => Hash{ Object => Numeric }] flowdict containing all
  #                                                   the flow values in the edges
  def self.build_flow_dict(g, _r_network)
    flow_dict = {}
    g.edges.each do |u, u_edges|
      flow_dict[u] = {}
      u_edges.each_key { |v| flow_dict[u][v] = 0 }
      u_edges.each { |v, uv_attrs| flow_dict[u][v] = uv_attrs[:flow] if uv_attrs[:flow] > 0 }
    end
    flow_dict
  end
end
