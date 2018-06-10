module NetworkX
  def self.to_matrix(g, multigraph_weight='sum')
    is_undirected = !g.is_directed
    is_multigraph = g.is_multigraph
    nodelen = g.nodes.length

    m = NMatrix.new(nodelen, Float::INFINITY)
    index = {}
    inv_index = {}
    ind = 0

    g.nodes.each do |u, _|
      index[u] = ind
      inv_index[ind] = u
      ind += 1
    end

    if is_multigraph
      g.adj.each do |u, edge_hash|
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
      g.adj.each do |u, edge_hash|
        edge_hash.each do |v, attrs|
          # binding.pry
          m[index[u], index[v]] = (attrs[:weight] || 1)
          m[index[v], index[u]] = (attrs[:weight] || 1) if is_undirected
        end
      end
    end
    [m, inv_index]
  end
end
