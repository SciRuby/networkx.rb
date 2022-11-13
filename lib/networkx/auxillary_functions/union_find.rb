# Refer to: C00 https://github.com/universato/ac-library-rb/blob/main/lib/dsu.rb
# Refer to: https://networkx.org/documentation/stable/_modules/networkx/utils/union_find.html#UnionFind.union
module NetworkX
  # Union Find Tree
  #
  # @attr_reader parents [Hash{ Object => Object }] Return parent of each element
  # @attr_reader weights [Hash{ Object => Integer }] Return weight of each element
  class UnionFind
    attr_accessor :parents, :weights

    # Constructor for initializing Union Find Tree
    #
    # @param nodes [?Array[Object]] nodes
    #
    # @return [UnionFind] Union Find Tree
    def initialize(nodes=nil)
      @weights = {}
      @parents = {}
      nodes&.each do |node|
        @weights[node] = 1
        @parents[node] = node
      end
    end

    # Return the root of node
    #
    # @param node [Object] node
    #
    # @return [Object] root of node, leader of node
    def [](node)
      if @parents.has_key?(node)
        @parents[node] == node ? node : (@parents[node] = self[@parents[node]])
      else
        @weights[node] = 1
        @parents[node] = node
      end
    end

    # Return the root of node
    #
    # @param node [Object] node
    #
    # @return [Object] root of node, leader of node
    def root(node)
      @parents.has_key?(node) or raise ArgumentError.new, "#{node} is not a node"

      @parents[node] == node ? node : (@parents[node] = root(@parents[node]))
    end

    def each(&block)
      @parents.each_key(&block)
    end

    def to_sets
      each.group_by { |node| root(node) }.values
    end
    alias groups to_sets

    # Is each root of two nodes the same?
    #
    # @param node1 [Object] node
    # @param node2 [Object] node
    #
    # @return [bool] Is each root of node1 and nodes_2 the same?
    def connected?(node1, node2)
      root(node1) == root(node2)
    end
    alias same? connected?

    # Unite nodes.
    #
    # @param nodes [Array[Object]] nodes
    #
    # @return [Object | nil] root of united nodes
    def union(*nodes)
      return merge(*nodes) if nodes.size == 2

      roots = nodes.map { |node| self[node] }.uniq
      return if roots.size == 1

      roots.sort_by! { |root| @weights[root] }
      root = roots[-1]
      roots[0...-1].each do |r|
        @weights[root] += @weights[r]
        @parents[r] = root
      end
      root
    end
    alias unite union

    def merge(node1, node2)
      x = self[node1]
      y = self[node2]
      return if x == y

      x, y = y, x if @weights[x] < @weights[y]
      @weights[x] += @weights[y]
      @parents[y] = x
    end
  end
end
