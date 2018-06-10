def out_edges(g, u)
  edges = []
  visited = {}
  case g.class.name
  when 'NetworkX::Graph', 'NetworkX::DiGraph'
    g.adj[u].each do |v, _|
      if g.class.name == 'NetworkX::DiGraph' || !visited[[v, u]].nil?
        visited[[u, v]] = true
        edges << [u, v]
      end
    end
  else
    g.adj[u].each do |v, uv_keys|
      uv_keys.each_key do |k|
        if g.class.name == 'NetworkX::MultiDiGraph' || !visited[[v, u, k]].nil?
          visited[[u, v, k]] = true
          edges << [u, v, k]
        end
      end
    end
  end
  edges
end

module NetworkX
  def self.edge_dfs(g, start, orientation=nil)
    case orientation
    when :reverse
      g = g.reverse if g.class.name == 'NetworkX::DiGraph' || g.class.name == 'NetworkX::MultiDiGraph'
    when :ignore
      g = g.to_undirected if g.class.name == 'NetworkX::DiGraph'
      g = g.to_multigraph if g.class.name == 'NetworkX::MultiDiGraph'
    end

    visited_edges = []
    visited_nodes = []
    stack = [start]
    current_edges = {}

    e = Enumerator.new do |e|
      until stack.empty?
        current = stack.last
        unless visited_nodes.include?(current)
          current_edges[current] = out_edges(g, current)
          visited_nodes << current
        end

        edge = current_edges[current].shift
        if edge.nil?
          stack.pop
        else
          unless visited_edges.include?(edge)
            visited_edges << edge
            stack << edge[1]
            e.yield edge
          end
        end
      end
    end
    e.take(g.number_of_edges)
  end
end
