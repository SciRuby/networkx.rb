module NetworkX
  # Returns all cliques in the graph
  #
  # @param graph [Graph, MultiGraph] a graph
  #
  # @return [Array<Array<Object>>] Arrays of nodes in the cliques
  def self.find_cliques(graph)
    return nil if graph.nodes.length == 0
    q = [nil]
    adj = {}
    graph.nodes.each { |u, _| adj[u] = [] }
    graph.adj.each { |u, u_edges| u_edges.each { |v, _| adj[u] << v  if u != v } }

    subg = graph.nodes.keys
    cand = graph.nodes.keys
    u = subg.max { |n1, n2| (cand & adj[n1]).length <=> (cand & adj[n2]).length }
    ext_u = cand - adj[u]
    stack = []
    cliques = []
    begin
      while true
        if !ext_u.empty?
          q_elem = ext_u.pop
          cand.delete(q_elem)
          q[-1] = q_elem
          adj_q = adj[q_elem]
          subg_q = subg & adj_q
          if subg_q.empty?
            cliques << q[0..(q.length - 1)]
          else
            cand_q = cand & adj_q
            unless cand_q.empty?
              stack << [subg, cand, ext_u]
              q << nil
              subg = subg_q
              cand = cand_q
              u = subg.max { |n1, n2| (cand & adj[n1]).length <=> (cand & adj[n2]).length }
              ext_u = cand - adj[u]
            end
          end
        else
          q.pop
          subg, cand, ext_u = stack.pop
        end
      end
    rescue NoMethodError
      return cliques
    end
  end

  # Returns the number of cliques in a graph containing a node
  #
  # @param graph [Graph, MultiGraph] a graph
  # @param node [Object] a node
  #
  # @return [Numeric] Number of cliques containing the given node
  def self.number_of_cliques(graph, node)
    cliques = find_cliques(graph)
    num_cliq_arr = []
    cliques.each { |c| num_cliq_arr << 1 if c.include?(node) }
    num_cliq_arr.length
  end
end
