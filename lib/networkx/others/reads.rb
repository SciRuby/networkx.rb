require_relative '../../networkx'

module NetworkX
  class Graph
    class << self
      def read_edgelist(path, comment: '#', delimiter: nil)
        edges = File.readlines(path).filter_map do |line|
          line.sub!(/#{comment}.+/, '')
          line.strip.split(delimiter) if line.strip.size > 0
        end

        edges.each{|edge| edge.map!{|node| NetworkX.to_number_if_possible(node) } }

        graph = new
        graph.add_edges(edges)
        graph
      end
      alias read_edges read_edgelist

      def read_weighted_edgelist(path, comment: '#', delimiter: nil)
        edges = File.readlines(path).filter_map do |line|
          line.sub!(/#{comment}.+/, '')
          line.strip.split(delimiter) if line.strip.size > 0
        end

        edges.map! do |x, y, weight|
          [
            NetworkX.to_number_if_possible(x),
            NetworkX.to_number_if_possible(y),
            {weight: NetworkX.to_number_if_possible(weight)}
          ]
        end

        graph = new
        graph.add_edges(edges)
        graph
      end
      alias read_weighted_edges read_weighted_edgelist
    end
  end

  def self.to_number_if_possible(str)
    if str =~ /^[+-]?[0-9]+$/
      str.to_i
    elsif str =~ /^([+-]?\d*\.\d*)|(\d*[eE][+-]?\d+)$/
      str.to_f
    else
      str
    end
  end
end
