require 'spec_helper'

RSpec.describe NetworkX::Graph do
    it "creates an undirected graph with new constructor and attributes 'name: Distance, type: undirected'" do
        graph = NetworkX::Graph.new(name: "Cities", type: "undirected")
        expect(graph.graph).to eq({name: "Cities", type: "undirected"}) 
    end

    it "create a new node" do
        graph = NetworkX::Graph.new
        graph.add_node("Nagpur")
        graph.add_node("Mumbai")
        expect(graph.nodes).to eq({"Nagpur" => {}, "Mumbai" => {}})
    end

    it "create multiple nodes" do 
        graph = NetworkX::Graph.new
        graph.add_nodes(["Nagpur", "Mumbai", "Kharagpur"])
        expect(graph.nodes).to eq({"Nagpur" => {}, "Mumbai" => {}, "Kharagpur" => {}})
    end

    it "add edge" do
        graph = NetworkX::Graph.new
        graph.add_edge("Nagpur", "Mumbai")
        expect(graph.adj).to eq({"Nagpur" => {"Mumbai" => {}}, "Mumbai" => {"Nagpur" => {}}})
    end

    it "add multiple edges" do 
        graph = NetworkX::Graph.new
        graph.add_edges([["B", "N"], ["N", "M"]])
        expect(graph.nodes).to eq({"B" => {}, "N" => {}, "M" => {}})
        expect(graph.adj).to eq({"B" => {"N" => {}}, "N" => {"B" => {}, "M" => {}}, "M" => {"N" => {}}}) 
    end

    it "remove node" do
        graph = NetworkX::Graph.new
        graph.add_edge("B", "N")
        graph.add_edge("N", "M")
        graph.remove_node("N")
        expect(graph.nodes).to eq({"B" => {}, "M" => {}})
        expect(graph.adj).to eq("B" => {}, "M" => {})
    end

    it "remove nodes" do
        graph = NetworkX::Graph.new
        graph.add_edge("B", "N")
        graph.add_edge("N", "M")
        graph.remove_nodes(["B", "M"])
        expect(graph.nodes).to eq({"N" => {}})
        expect(graph.adj).to eq({"N" => {}})
    end
end
