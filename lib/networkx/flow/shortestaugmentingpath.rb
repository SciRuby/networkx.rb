# TODO: Reduce module length

module NetworkX
  # TODO: Reduce method complexity and method length

  # Helper function for running the shortest augmenting path algorithm
  def self.shortest_augmenting_path_impl(graph, source, target, residual, two_phase, cutoff)
    raise ArgumentError, 'Source is not in the graph!' unless graph.nodes.key?(source)
    raise ArgumentError, 'Target is not in the graph!' unless graph.nodes.key?(target)
    raise ArgumentError, 'Source and Target are the same!' if source == target

    residual = residual.nil? ? build_residual_network(graph) : residual
    r_nodes = residual.nodes
    r_pred = residual.pred
    r_adj = residual.adj

    r_adj.each_value do |u_edges|
      u_edges.each_value do |attrs|
        attrs[:flow] = 0
      end
    end

    heights = {target => 0}
    q = [[target, 0]]

    until q.empty?
      u, height = q.shift
      height += 1
      r_pred[u].each do |v, attrs|
        if !heights.key?(v) && attrs[:flow] < attrs[:capacity]
          heights[v] = height
          q << [v, height]
        end
      end
    end

    unless heights.key?(source)
      residual.graph[:flow_value] = 0
      return residual
    end

    n = graph.nodes.length
    m = residual.size / 2

    r_nodes.each do |node, attrs|
      attrs[:height] = heights.key?(node) ? heights[node] : n
      attrs[:curr_edge] = CurrentEdge.new(r_adj[node])
    end

    counts = Array.new((2 * n) - 1, 0)
    counts.fill(0)
    r_nodes.each_value { |attrs| counts[attrs[:height]] += 1 }
    inf = graph.graph[:inf]

    cutoff = Float::INFINITY if cutoff.nil?
    flow_value = 0
    path = [source]
    u = source
    d = two_phase ? n : [m**0.5, 2 * (n**(2./ 3))].min.floor
    done = r_nodes[source][:height] >= d

    until done
      height = r_nodes[u][:height]
      curr_edge = r_nodes[u][:curr_edge]

      loop do
        v, attr = curr_edge.get
        if height == r_nodes[v][:height] + 1 && attr[:flow] < attr[:capacity]
          path << v
          u = v
          break
        end
        begin
          curr_edge.move_to_next
        rescue StopIteration
          if counts[height].zero?
            residual.graph[:flow_value] = flow_value
            return residual
          end
          height = relabel(u, n, r_adj, r_nodes)
          if u == source && height >= d
            if two_phase
              done = true
              break
            else
              residual.graph[:flow_value] = flow_value
              return residual
            end
          end
          counts[height] += 1
          r_nodes[u][:height] = height
          unless u == source
            path.pop
            u = path[-1]
            break
          end
        end
      end
      next unless u == target

      flow_value += augment(path, inf, r_adj)
      if flow_value >= cutoff
        residual.graph[:flow_value] = flow_value
        return residual
      end
    end
    flow_value += edmondskarp_core(residual, source, target, cutoff - flow_value)
    residual.graph[:flow_value] = flow_value
    residual
  end

  # TODO: Reduce method complexity and method length

  # Helper function for augmenting flow
  def augment(path, inf, r_adj)
    flow = inf
    temp_path = path.clone
    u = temp_path.shift
    temp_path.each do |v|
      attr = r_adj[u][v]
      flow = [flow, attr[:capacity] - attr[:flow]].min
      u = v
    end
    raise ArgumentError, 'Infinite capacity path!' if flow * 2 > inf

    temp_path = path.clone
    u = temp_path.shift
    temp_path.each do |v|
      r_adj[u][v][:flow] += flow
      r_adj[v][u][:flow] -= flow
      u = v
    end
    flow
  end

  # Helper function to relable a node to create a permissible edge
  def self.relabel(node, num, r_adj, r_nodes)
    height = num - 1
    r_adj[node].each do |v, attrs|
      height = [height, r_nodes[v][:height]].min if attrs[:flow] < attrs[:capacity]
    end
    height + 1
  end

  # Computes max flow using shortest augmenting path algorithm
  #
  # @param graph [DiGraph] a graph
  # @param source [Object] source node
  # @param target [Object] target node
  # @param residual [DiGraph, nil] residual graph
  # @param value_only [Boolean] if true, compute only the maximum flow value
  # @param two_phase [Boolean] if true, two phase variant is used
  # @param cutoff [Numeric] cutoff value for the algorithm
  #
  # @return [DiGraph] a residual graph containing the flow values
  def self.shortest_augmenting_path(graph, source, target, residual=nil, _value_only=false, two_phase=false, cutoff=nil)
    shortest_augmenting_path_impl(graph, source, target, residual, two_phase, cutoff)
  end
end
