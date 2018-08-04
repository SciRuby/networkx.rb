require 'pry'
module NetworkX
  def self.wiener_index(graph)
    total = all_pairs_shortest_path_length(graph)
    wiener_ind = 0
    Hash[total].each { |_, distances| Hash[distances].each { |_, val| wiener_ind += val } }
    graph.directed? ? wiener_ind : wiener_ind / 2
  end
end