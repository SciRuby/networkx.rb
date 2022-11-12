module NetworkX
  # Returns all basis cycles in graph
  #
  # @param graph [Graph] a graph
  # @param root [Object, Nil] root for the graph cycles
  #
  # @return [Array<Array<Object>>] Arrays of nodes in the cycles
  def self.cycle_basis(graph, root=nil)
    gnodes = graph.nodes.keys
    cycles = []
    until gnodes.empty?
      root = gnodes.shift if root.nil?
      stack = [root]
      pred = {root => root}
      used = {root => []}
      until stack.empty?
        z = stack.shift
        zused = used[z]
        graph.adj[z].each_key do |u|
          if !used.has_key?(u)
            pred[u] = z
            stack << u
            used[u] = [z]
          elsif u == z
            cycles << [z]
          elsif !zused.include?(u)
            pn = used[u]
            cycle = [u, z]
            p = pred[z]
            until pn.include?(p)
              cycle << p
              p = pred[p]
            end
            cycle << p
            cycles << cycle
            used[u] << z
            used[u] = used[u].uniq
          end
        end
      end
      gnodes -= pred.keys
      root = nil
    end
    cycles
  end

  # Returns the cycle containing the given node
  #
  # @param graph [Graph, DiGraph] a graph
  # @param node [Object] node to be included in the cycle
  #
  # @return [Array<Array<Object>>] Arrays of nodes in the cycle
  def self.find_cycle(graph, node)
    explored = Set.new
    cycle = []
    final_node = nil
    unless explored.include?(node)
      edges = []
      seen = [node]
      active_nodes = [node]
      previous_head = nil

      edge_dfs(graph, node).each do |edge|
        tail, head = edge
        next if explored.include?(head)

        if !previous_head.nil? && tail != previous_head
          loop do
            popped_edge = edges.pop
            if popped_edge.nil?
              edges = []
              active_nodes = [tail]
              break
            else
              popped_head = popped_edge[1]
              active_nodes.delete!(popped_head)
            end

            unless edges.empty?
              last_head = edges[-1][1]
              break if tail == last_head
            end
          end
        end
        edges << edge

        if active_nodes.include?(head)
          cycle += edges
          final_node = head
          break
        else
          seen << head
          active_nodes << head
          previous_head = head
        end
      end
      cycle.each_with_index { |edge, i| return cycle[i..(cycle.length - 1)] if final_node == edge[0] }
    end
    raise ArgumentError, 'No cycle found!' if cycle.empty?
  end
end
