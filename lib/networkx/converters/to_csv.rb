# frozen_string_literal: true

module NetworkX
  # TODO: Reduce method length and method complexity

  # Saves the graph in a csv file
  #
  # @param graph [Graph, DiGraph, MultiGraph, MultiDiGraph] a graph
  # @param filename [String] filename of the graph
  def self.graph_to_csv(graph, filename='graph.csv')
    CSV.open(filename, 'wb') do |csv|
      csv << [graph.class.name]
      csv << ['graph_values']
      csv << graph.graph.keys
      csv << graph.graph.values
      csv << ['graph_nodes']
      graph.nodes.each do |u, attrs|
        node_attrs = [u]
        attrs.each do |k, v|
          node_attrs << k
          node_attrs << v
        end
        csv << node_attrs
      end
      csv << ['graph_edges']
      graph.adj.each do |u, u_edges|
        u_edges.each do |v, uv_attrs|
          if graph.multigraph?
            uv_attrs.each do |key, attrs|
              node_attrs = [u, v, key]
              attrs.each do |k, k_attrs|
                node_attrs << k
                node_attrs << k_attrs
              end
              csv << node_attrs
            end
          else
            node_attrs = [u, v]
            uv_attrs.each do |k, vals|
              node_attrs << k
              node_attrs << vals
            end
            csv << node_attrs
          end
        end
      end
    end
  end
end
