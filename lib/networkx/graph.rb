module NetworkX
    class Graph

        attr_reader :node, :adj

        def initialize(incoming_graph_data=nil, **graph_attr) 
            @graph = Hash.new 
            @node = Hash.new
            @adj = Hash.new

            if incoming_graph_data != nil
                # Not yet implemented!
            end

            @graph.merge!(graph_attr)
        end

        def name
            @graph["name"]
        end

        def name(name_val)
            @graph["name"] = name_val
        end

        def to_s
            @graph["name"]
        end

        def add_node(node_for_adding, **node_attr)
            if !@node.key?(node_for_adding)
                @node[node_for_adding] = node_attr.clone
                @adj[node_for_adding] = Hash.new
            else
                @node[node_for_adding].merge!(node_attr)
            end
        end

        def add_nodes_from(*nodes, **nodes_attrs)
            nodes.each do |n|
                if !@node.key?(n)
                    @node[n] = nodes_attr.clone
                    @adj[n] = Hash.new
                else
                    @node[n].merge!(nodes_attrs)
                end
            end
        end
        
        def add_edge(u, v, **edge_attrs)
            if !@node.key?(u)
                @node[u] = Hash.new
                @adj[u] = Hash.new
            end
            if !@node.key?(v)
                @node[v] = Hash.new 
                @adj[v] = Hash.new 
            end

            edge_attr_hash = Hash.new

            if @adj[u].key?(v)
            edge_attr_hash = @adj[u][v] 
            end

            edge_attr_hash.merge!(edge_attrs)

            @adj[u][v] = edge_attr_hash
            @adj[v][u] = edge_attr_hash
        end

        def remove_edge(u, v)
            begin
                @adj[u].delete(v)
                if u != v
                    @adj[v].delete(u)
                end
            rescue NoMethodError, KeyError
                raise NetworkXError, "There exists no edge between #{u} and #{v}"
            end
        end
    end
end
