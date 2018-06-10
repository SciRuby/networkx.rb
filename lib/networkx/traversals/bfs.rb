module NetworkX
  def self.bfs_edges(g, source)
    raise KeyError, "There exists no node names #{source} in the given graph." unless g.node?(source)
    bfs_edges = []
    visited = [source]
    queue = Queue.new.push([source, g.neighbours(source)])
    until queue.empty?
      parent, children = queue.pop
      children.each_key do |child|
        next if visited.include?(child)
        bfs_edges << [parent, child]
        visited << child
        queue.push([child, g.neighbours(child)])
      end
    end
    bfs_edges
  end

  def self.bfs_successors(g, source)
    bfs_edges = bfs_edges(g, source)
    parent = source
    successors = {}
    bfs_edges.each do |u, v|
      successors[u] = [] if successors[u].nil?
      successors[u] << v
    end
    successors
  end

  def self.bfs_predecessors(g, source)
    bfs_edges = bfs_edges(g, source)
    predecessors = {}
    bfs_edges.each { |u, v| predecessors[v] = u }
    predecessors
  end
end
