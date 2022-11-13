require_relative '../../networkx'

module NetworkX
  class Graph
    # private class method
    def self.complete_edges(n)
      n = (0...n) if n.is_a?(Integer)

      edges = []
      n.each do |i|
        n.each do |j|
          edges << [i, j] if i < j
        end
      end
      edges
    end

    def self.balanced_tree(r, h)
      edges = []
      q = [0]
      i = 0
      h.times do
        t = q.dup
        q.clear
        t.each do |v|
          r.times do
            i += 1
            edges << [v, i]
            q << i
          end
        end
      end
      graph = new(name: "balanced_tree(#{r}, #{h})")
      graph.add_edges(edges)
      graph
    end

    def self.barbell_graph(m1, m2)
      edges = complete_edges(m1)
      edges.concat((m1..m2 + m1).map { |k| [k - 1, k] })
      edges.concat complete_edges(m1 + m2...m1 + m2 + m1)

      graph = new(name: "barbell_graph(#{m1}, #{m2})")
      graph.add_edges(edges)
      graph
    end

    def self.complete_graph(n)
      n = (0...n) if n.is_a?(Integer)

      edges = []
      n.each do |i|
        n.each do |j|
          edges << [i, j] if i < j
        end
      end

      graph = new(name: "complete_graph(#{n})")
      graph.add_edges(edges)
      graph
    end

    def self.circular_ladder_graph(n)
      edges = (0...n - 1).map { |v| [v, v + 1] }
      edges << [n - 1, 0]
      edges.concat((n...2 * n - 1).map { |v| [v, v + 1] })
      edges << [2 * n - 1, n]
      edges.concat((0...n).map { |v| [v, v + n] })

      graph = new(name: "circular_ladder_graph(#{n})")
      graph.add_edges(edges)
      graph
    end

    def self.cycle_graph(n)
      edges = (0...n - 1).map { |v| [v, v + 1] }
      edges << [n - 1, 0]

      graph = new(name: "cycle_graph(#{n})")
      graph.add_edges(edges)
      graph
    end

    def self.empty_graph(number_of_nodes)
      empty_graph = new(name: "empty_graph#{number_of_nodes}")
      empty_graph.add_nodes_from(0...number_of_nodes)
      empty_graph
    end

    def self.ladder_graph(n)
      edges = (0...n - 1).map { |k| [k, k + 1] }
      edges.concat((n...2 * n - 1).map { |k| [k, k + 1] })
      edges.concat((0...n).map { |k| [k, k + n] })

      graph = new(name: "ladder_graph(#{n})")
      graph.add_edges(edges)
      graph
    end

    def self.lollipop_graph(m, n)
      edges = complete_edges(m)
      edges.concat((m - 1...m - 1 + n).map { |v| [v, v + 1] })

      graph = new(name: "lollipop_graph(#{m}, #{n})")
      graph.add_edges(edges)
      graph
    end

    def self.null_graph
      new(name: 'null_graph')
    end

    def self.path_graph(n)
      edges = (0...n - 1).map { |v| [v, v + 1] }

      graph = new(name: "path_graph(#{n})")
      graph.add_edges(edges)
      graph
    end

    def self.star_graph(n)
      edges = (1..n).map { |i| [0, i] }

      graph = new(name: "star_graph(#{n})")
      graph.add_edges(edges)
      graph
    end

    def self.trivial_graph
      trivial_graph = new(name: 'trivial_grpph')
      trivial_graph.add_node(0)
      trivial_graph
    end

    def self.wheel_graph(n)
      edges = (1..n - 1).map { |i| [0, i] }
      edges.concat((1...n - 1).map { |i| [i, i + 1] })
      edges << [1, n - 1]

      graph = new(name: "wheel_graph(#{n})")
      graph.add_edges(edges)
      graph
    end

    def self.bull_graph
      edges = [[0, 1], [1, 2], [2, 0], [1, 3], [2, 4]]
      graph = new(name: 'bull_graph')
      graph.add_edges(edges)
      graph
    end

    def self.cubical_graph
      graph = circular_ladder_graph(4)
      graph.graph[:name] = 'cubical_graph'
      graph
    end

    def self.diamond_graph
      edges = [[0, 1], [0, 2], [1, 2], [1, 3], [2, 3]]
      graph = new(name: 'diamond_graph')
      graph.add_edges(edges)
      graph
    end

    # 12
    def self.dodecahedral_graph
      edges = (0...19).map { |k| [k, k + 1] }
      edges.concat [[0, 19], [0, 10], [1, 8], [2, 6], [3, 19], [4, 17], [5, 15], [7, 14], [9, 13], [11, 18], [12, 16]]
      graph = new(name: 'dodecahedral_graph')
      graph.add_edges(edges)
      graph
    end

    def self.heawood_graph
      edges = (0...13).map { |k| [k, k + 1] }
      edges << [13, 0]
      edges.concat [[0, 5], [1, 10], [2, 7], [3, 12], [4, 9], [6, 11], [8, 13]]
      graph = new(name: 'heawood_graph')
      graph.add_edges(edges)
      graph
    end

    def self.house_graph
      edges = [[0, 1], [0, 2], [1, 3], [2, 3], [2, 4], [3, 4]]
      graph = new(name: 'house_graph')
      graph.add_edges(edges)
      graph
    end

    def self.house_x_graph
      edges = (0...4).map { |k| [k, k + 1] }
      edges.concat [[0, 2], [0, 3], [1, 3], [2, 4], [3, 4]]
      graph = new(name: 'house_x_graph')
      graph.add_edges(edges)
      graph
    end

    def self.moebius_kantor_graph
      edges = (0...15).map { |k| [k, k + 1] }
      edges << [15, 0]
      edges.concat [[0, 5], [1, 12], [2, 7], [4, 9], [3, 14], [6, 11], [8, 13], [10, 15]]
      graph = new(name: 'moebius_kantor_graph')
      graph.add_edges(edges)
      graph
    end

    # 8: 6 nodes, 12 edges
    def self.octahedral_graph
      edges = []
      6.times do |i|
        6.times do |j|
          edges << [i, j] if i != j && i + j != 5
        end
      end
      graph = new(name: 'octahedral_graph')
      graph.add_edges(edges)
      graph
    end

    def self.tetrahedral_graph
      graph = complete_graph(4)
      graph.graph[:name] = 'tetrahedral_graph'
      graph
    end

    # Experimental For debug.
    #
    # @return data for https://hello-world-494ec.firebaseapp.com/
    def put_graph_x2
      output = <<~"OUTPUT"
        #{number_of_nodes} #{number_of_edges}
        #{edges.map { |edge| edge.join(' ') }.join("\n")}
      OUTPUT
      puts output
    end
  end
end
