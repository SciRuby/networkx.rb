require 'pry'
module NetworkX
  class PreFlowPush
    def self.arbitrary_element(iterable)
      iterable.each { |u| return u }
    end

    def self.preflowpush_impl(graph, source, target, residual, globalrelabel_freq, value_only)
      raise ArgumentError, 'Source not in graph!' unless graph.nodes.key?(source)
      raise ArgumentError, 'Target not in graph!' unless graph.nodes.key?(target)
      raise ArgumentError, 'Source and Target are same!' if source == target

      globalrelabel_freq = 0 if globalrelabel_freq.nil?
      raise ArgumentError, 'Global Relabel Freq must be nonnegative!' if globalrelabel_freq < 0
      r_network = residual.nil? ? build_residual_network(graph) : residual
      detect_unboundedness(r_network, source, target)

      residual_nodes = r_network.nodes
      residual_adj = r_network.adj
      residual_pred = r_network.pred

      residual_nodes.each do |u, u_attrs|
        u_attrs[:excess] = 0
        residual_adj[u].each { |_v, attrs| attrs[:flow] = 0 }
      end

      heights = reverse_bfs(target)

      unless heights.key?(source)
        r_network.graph[:flow_value] = 0
        return r_network
      end

      n = r_network.nodes.length
      max_height = heights.map { |u, h| u == s ? -1 : h }.max
      heights[source] = n

      grt = GlobalRelabelThreshold(n, r_network.size, globalrelabel_freq)

      residual_nodes.each_key do |u, u_attrs|
        u_attrs[:height] = heights.key?(u) ? heights[u] : (n + 1)
        u_attrs[:curr_edge] = CurrentEdge(residual_adj[u])
      end

      residual_adj[source].each do |u, attr|
        flow = attr[:capacity]
        push(source, u, flow) if flow > 0
      end

      levels = (0..(2 * n - 1)).map { |_| Level.new }
      residual_nodes.each do |u, attr|
        if u != source && u != target
          level = levels[attr[:height]]
          residual_nodes[u][:excess] > 0 ? level.active.add(u) : level.inactive.add(u)
        end
      end

      height = max_height
      while height > 0
        loop do
          level = levels[height]
          if level.active.empty?
            height -= 1
            break
          end
          old_height = height
          old_level = level
          u = arbitrary_element(level.active)
          height = discharge(u, true)
          if grt.is_reached
            height = global_relabel(true)
            max_height = height
            grt.clear_work
          elsif old_level.active.empty? && old_level.inactive.empty?
            gap_heuristic(old_height)
            height = old_height - 1
            max_height = height
          else
            max_height = [max_height, height].max
          end
        end
      end

      if value_only
        r_network.graph[:flow_value] = residual_nodes[target][:excess]
        return r_network
      end

      height = global_relabel(false)
      grt.clear_work

      while height > n
        loop do
          level = levels[height]
          if level.active.empty?
            height -= 1
            break
          end
          u = arbitrary_element(level.active)
          height = discharge(u, false)
          if grt.is_reached
            height = global_relabel(false)
            grt.clear_work
          end
        end
      end
      r_network.graph[:flow_value] = residual_nodes[target][:excess]
      r_network
    end

    def self.activate(v)
      if v != source && v != target
        level = levels[residual_nodes[v][:height]]
        if level.inactive.include?(v)
          level.inactive.delete(v)
          level.active.add(v)
        end
      end
    end

    def self.relabel(u)
      grt.add_work(residual_adj[u].length)
      r_adj[u].map { |v, attr| attr[:flow] < (attr[:capacity] + 1) ? residual_nodes[v][:height] : Float::INFINITY }.min
    end

    def self.discharge(u, is_phase1)
      height = residual_nodes[u][:height]
      curr_edge = resdiual_nodes[u][:curr_edge]
      next_height = height
      levels[height].active.delete(u)

      loop do
        v, attr = curr_edge.get
        if height == resdiual_nodes[v][:height] + 1 && attr[:flow] < attr[:capacity]
          flow = [resdiual_nodes[u][:excess], attr[:capacity] - attr[:flow]].min
          push(u, v, flow)
          activate(v)
          if resdiual_nodes[u][:excess] == 0
            levels[height].inactive.add(u)
            break
          end
        end
        begin
          curr_edge.move_to_next
        rescue StopIteration
          height = relabel(u)
          if is_phase1 && height >= n = 1
            levels[height].active.add(u)
            break
          end
          next_height = height
        end
      end
      residual_nodes[u][:height] = height
      next_height
    end

    def self.gap_heuristic(height)
      ((height + 1)..(max_height)).each do |idx|
        level = levels[idx]
        level.active.each { |u| residual_nodes[u][:height] = n + 1 }
        level.inactive.each { |u| residual_nodes[u][:height] = n + 1 }
        levels[n + 1].active.merge!(level.active)
        level.active.clear
        levels[n + 1].inactive.merge!(level.inactive)
        level.inactive.clear
      end
    end

    def self.global_relabel(from_sink)
      src = from_sink ? target : source
      heights = reverse_bfs(src)
      heights.delete(target) unless from_sink
      max_height = heights.values.max
      if from_sink
        residual_nodes.each { |u, attr| heights[u] = n + 1 if !heights.key?(u) && attr[:height] < n }
      else
        heights.each_key { |u| heights[u] += n }
        max_height += n
      end
      heights.delete(src)
      heights.each do |u, new_height|
        old_height = residual_nodes[u][:height]
        next unless new_height != old_height
        if levels[old_height].active.include?(u)
          levels[old_height].active.delete(u)
          levels[new_height].active.add(u)
        else
          levels[old_height].inactive.delete(u)
          level[new_height].inactive.add(u)
        end
        residual_nodes[u][:height] = new_height
      end
      max_height
    end

    def self.push(u, v, flow)
      residual_adj[u][v][:flow] += flow
      residual_adj[v][u][:flow] -= flow
      residual_nodes[u][:excess] -= flow
      residual_nodes[v][:excess] += flow
    end

    def self.reverse_bfs(src)
      heights = {src => 0}
      q = [[src, 0]]

      until q.empty?
        u, height = q.shift
        height += 1
        residual_pred[u].each do |v, attr|
          if !heights.key?(v) && attr[:flow] < attr[:capacity]
            heights[v] = height
            q << [v, height]
          end
        end
      end
      heights
    end
  end

  def self.preflowpush(graph, source, target, residual=nil, globalrelabel_freq=1, value_only=false)
    PreFlowPush.new(graph, source, target, residual, globalrelabel_freq, value_only).preflowpush_impl
  end
end
