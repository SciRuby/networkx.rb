# frozen_string_literal: true

# TODO: Reduce module length

module NetworkX
  # Returns a label for unique node
  def self.generate_unique_node
    SecureRandom.uuid
  end

  # Finds if there is a negative edge cycle in the graph
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  #
  # @return [Boolean] whether there exists a negative cycle in graph
  def self.negative_edge_cycle(graph)
    newnode = generate_unique_node
    graph.add_edges(graph.nodes.keys.map { |n| [newnode, n] })
    begin
      bellmanford_predecesor_distance(graph, newnode)
    rescue ArgumentError
      return true
    ensure
      graph.remove_node(newnode)
    end
    false
  end

  # TODO: Reduce method complexity and method length

  # Detects the unboundedness in the residual graph
  def self._detect_unboundedness(residual)
    g = NetworkX::DiGraph.new
    g.add_nodes(residual.nodes.keys.zip(residual.nodes.values))
    inf = residual.graph[:inf]

    residual.nodes.each do |u, _attr|
      residual.adj[u].each do |v, uv_attrs|
        w = inf
        uv_attrs.each { |_key, edge_attrs| w = [w, edge_attrs[:weight]].min if edge_attrs[:capacity] == inf }
        g.add_edge(u, v, weight: w) unless w == inf
      end
    end
    raise ArgumentError, 'Negative cost cycle of infinite capacity found!' if negative_edge_cycle(g)
  end

  # TODO: Reduce method complexity and method length

  # Returns the residual graph of the given graph
  def self._build_residual_network(graph)
    raise ArgumentError, 'Sum of demands should be 0!' unless \
                         graph.nodes.values.map { |attr| attr[:demand] || 0 }.inject(0, :+).zero?

    residual = NetworkX::MultiDiGraph.new(inf: 0)
    residual.add_nodes(graph.nodes.map { |u, attr| [u, {excess: (attr[:demand] || 0) * -1, potential: 0}] })
    inf = Float::INFINITY
    edge_list = []

    # TODO: Selfloop edges check

    if graph.multigraph?
      graph.adj.each do |u, u_edges|
        u_edges.each do |v, uv_edges|
          uv_edges.each do |k, attrs|
            edge_list << [u, v, k, e] if u != v && (attrs[:capacity] || inf).positive?
          end
        end
      end
    else
      graph.adj.each do |u, u_edges|
        u_edges.each do |v, attrs|
          edge_list << [u, v, 0, attrs] if u != v && (attrs[:capacity] || inf).positive?
        end
      end
    end

    temp_inf = [residual.nodes.map { |_u, attrs| attrs[:excess].abs }.inject(0, :+), edge_list.map do |_, _, _, e|
      (e.key?(:capacity) && e[:capacity] != inf ? e[:capacity] : 0)
    end.inject(0, :+) * 2].max
    inf = temp_inf.zero? ? 1 : temp_inf

    edge_list.each do |u, v, k, e|
      r = [e[:capacity] || inf, inf].min
      w = e[:weight] || 0
      residual.add_edge(u, v, temp_key: [k, true], capacity: r, weight: w, flow: 0)
      residual.add_edge(v, u, temp_key: [k, false], capacity: 0, weight: -w, flow: 0)
    end
    residual.graph[:inf] = inf
    _detect_unboundedness(residual)
    residual
  end

  # TODO: Reduce method complexity and method length

  # Returns the flowdict of the graph
  def self._build_flow_dict(graph, residual)
    flow_dict = {}
    inf = Float::INFINITY

    if graph.multigraph?
      graph.nodes.each_key do |u|
        flow_dict[u] = {}
        graph.adj[u].each do |v, uv_edges|
          flow_dict[u][v] = uv_edges.transform_values do |e|
            u != v || (e[:capacity] || inf) <= 0 || (e[:weight] || 0) >= 0 ? 0 : e[:capacity]
          end
        end
        residual.adj[u].each do |v, uv_edges|
          flow_dict[u][v].merge!(uv_edges.to_h do |_, val|
                                   [val[:temp_key][0], val[:flow]] if (val[:flow]).positive?
                                 end)
        end
      end
    else
      graph.nodes.each_key do |u|
        flow_dict[u] = graph.adj[u].to_h do |v, e|
          [v, u != v || (e[:capacity] || inf) <= 0 || (e[:weight] || 0) >= 0 ? 0 : e[:capacity]]
        end
        merge_dict = {}
        residual.adj[u].each do |v, uv_edges|
          uv_edges.each_value { |attrs| merge_dict[v] = attrs[:flow] if (attrs[:flow]).positive? }
        end
        flow_dict[u].merge!(merge_dict)
      end
    end
    flow_dict
  end

  # Counter for the algorithm
  @itr = 0
  def self.count
    @itr += 1
    @itr
  end

  # TODO: Reduce method complexity and method length

  # Computes max flow using capacity scaling algorithm
  #
  # @param graph [DiGraph, MultiDiGraph] a graph
  #
  # @return [Array<Numeric, Hash{ Object => Hash{ Object => Numeric } }>]
  #          flow cost and flowdict containing all the flow values in the edges
  def self.capacity_scaling(graph)
    residual = _build_residual_network(graph)
    inf = Float::INFINITY
    flow_cost = 0

    # TODO: Account cost of self-loof edges

    wmax = ([-inf] + residual.adj.each_with_object([]) do |u, arr|
                       u[1].each { |_, key_attrs| key_attrs.each { |_, attrs| arr << attrs[:capacity] } }
                     end).max

    return flow_cost, _build_flow_dict(graph, residual) if wmax == -inf

    r_nodes = residual.nodes
    r_adj = residual.adj

    delta = 2 ** Math.log2(wmax).floor
    while delta >= 1
      r_nodes.each do |u, u_attrs|
        p_u = u_attrs[:potential]
        r_adj[u].each do |v, uv_edges|
          uv_edges.each do |_k, e|
            flow = e[:capacity]
            next unless (e[:weight] - p_u + r_nodes[v][:potential]).negative?

            flow = e[:capacity] - e[:flow]
            next unless flow >= delta

            e[:flow] += flow
            r_adj[v][u].each_key do |val|
              val[:flow] += val[:temp_key][0] == e[:temp_key][0] && val[:temp_key][1] != e[:temp_key][1] ? -flow : 0
            end
            r_nodes[u][:excess] -= flow
            r_nodes[v][:excess] += flow
          end
        end
      end

      s_set = Set.new
      t_set = Set.new

      residual.nodes.each do |u, _attrs|
        excess = r_nodes[u][:excess]
        if excess >= delta
          s_set.add(u)
        elsif excess <= -delta
          t_set.add(u)
        end
      end

      while !s_set.empty? && !t_set.empty?
        s = arbitrary_element
        t = nil
        d = {}
        pred = {s => nil}
        h = Heap.new { |x, y| x[0] < y[0] || (x[0] == y[0] && x[1] < y[1]) }
        h_dict = {s => 0}
        h << [0, count, s]
        until h.empty?
          d_u, _, u = h.pop
          h_dict.delete(u)
          d[u] = d_u
          if t_set.include?(u)
            t = u
            break
          end
          p_u = r_nodes[u][:potential]
          r_adj[u].each do |v, uv_edges|
            next if d.key?(v)

            wmin = inf
            uv_edges.each_value do |e|
              next unless e[:capacity] - e[:flow] >= delta

              w = e[:weight]
              next unless w < wmin

              wmin = w
            end
            next if wmin == inf

            d_v = d_u + wmin - p_u + r_nodes[v][:potential]
            next unless h_dict[v] > d_v

            h << [d_v, count, v]
            h_dict[v] = d_v
            pred[v] = [u, kmin, emin]
          end
        end

        if t.nil?
          s_set.delete(s)
        else
          while u != s
            v = u
            u, k, e = pred[v]
            e[:flow] += delta
            r_adj[v][u].each_key do |val|
              val[:flow] += val[:temp_key][0] == k[0] && val[:temp_key][1] != k[1] ? -delta : 0
            end
          end
          r_nodes[s][:excess] -= delta
          r_nodes[t][:excess] += delta
          s_set.delete(s) if r_nodes[s][:excess] < delta
          t_set.delete(t) if r_nodes[t][:excess] > -delta
          d_t = d[t]
          d.each { |node, d_u_node| r_nodes[node][:potential] -= (d_u_node - d_t) }
        end
      end
      delta = (delta / 2).floor
    end

    r_nodes.each_value { |attrs| raise ArgumentError, 'No flow satisfying all demands!' if attrs[:excess] != 0 }

    residual.nodes.each_key do |node|
      residual.adj[node].each_value do |uv_edges|
        uv_edges.each_value do |k_attrs|
          flow = k_attrs[:flow]
          flow_cost += (flow * k_attrs[:weight])
        end
      end
    end
    [flow_cost, _build_flow_dict(graph, residual)]
  end
end
