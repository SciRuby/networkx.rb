module NetworkX
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
            uv_attrs.each do |k, v|
              node_attrs << k
              node_attrs << v
            end
            csv << node_attrs
          end
        end
      end
    end
  end

  '''def self.csv_to_graph(filename)
    graph_csv = CSV.read(filename)
    graph_class = graph_csv.shift
    case graph_class[0]
    when "NetworkX::Graph"
      graph = NetworkX::Graph.new
    when "NetworkX::MultiGraph"
      graph = NetworkX::MultiGraph.new
    when "NetworkX::DiGraph"
      graph = NetworkX::DiGraph.new
    when "NetworkX::MultiDiGraph"
      graph = NetworkX::MultiDiGraph.new
    end

  end
  '''
end