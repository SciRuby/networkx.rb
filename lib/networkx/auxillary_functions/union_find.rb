module NetworkX
  class UnionFind
    def initialize(nodes)
      @unions = {}
      nodes.each_with_index do |node, index|
        @unions[node] = index
      end
    end

    def connected?(node_1, node_2)
      @unions[node_1] == @unions[node_2]
    end

    def union(node_1, node_2)
      return if connected?(node_1, node_2)
      node1_id = @unions[node_1]
      node2_id = @unions[node_2]

      @unions.each do |node, id|
        @unions[node] = node1_id if id == node2_id
      end
    end
  end
end
