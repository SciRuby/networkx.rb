module NetworkX
  def self.floyd_warshall(g)
    a, index = to_matrix(g, multigraph_weight='min')
    nodelen = g.nodes.length
    (0..(nodelen - 1)).each { |i| a[i, i] = 0 }
    (0..(nodelen - 1)).each do |k|
      (0..(nodelen - 1)).each do |i|
        (0..(nodelen - 1)).each do |j|
          a[i, j] = [a[i, j], a[i, k] + a[k, j]].min
        end
      end
    end

    as_hash = {}
    (0..(nodelen - 1)).each do |i|
      (0..(nodelen - 1)).each do |j|
        as_hash[index[i]] = {} unless as_hash.key?(index[i])
        as_hash[index[i]][index[j]] = a[i, j]
      end
    end
    as_hash
  end
end
