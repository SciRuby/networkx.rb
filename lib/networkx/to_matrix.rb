module NetworkX 
  def self.to_matrix(graph, val , multigraph_weight='sum')
    is_undirected = !graph.directed?
    is_multigraph = graph.multigraph?
    nodelen = graph.nodes.length

    m = NMatrix.new(nodelen, val)
    index = {}
    inv_index = {}
    ind = 0

    graph.nodes.each do |u, _|
      index[u] = ind
      inv_index[ind] = u
      ind += 1
    end

    if is_multigraph
      graph.adj.each do |u, edge_hash|
        edge_hash.each do |v, keys|
          all_weights = []
          keys.each do |_key, attrs|
            all_weights << attrs[:weight]
          end

          edge_attr = 0

          case multigraph_weight
          when 'sum'
            edge_attr = all_weights.inject(0, :+)
          when 'max'
            edge_attr = all_weights.max
          when 'min'
            edge_attr = all_weights.min
          end

          m[index[u], index[v]] = edge_attr
          m[index[v], index[u]] = edge_attr || 1 if is_undirected
        end
      end
    else
      graph.adj.each do |u, edge_hash|
        edge_hash.each do |v, attrs|
          m[index[u], index[v]] = (attrs[:weight] || 1)
          m[index[v], index[u]] = (attrs[:weight] || 1) if is_undirected
        end
      end
    end
    [m, inv_index]
  end
end
