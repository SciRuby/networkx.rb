RSpec.describe NetworkX::Graph do
  it 'test empty' do
    uf = NetworkX::UnionFind.new
    expect(uf.parents).to eq({})
    expect(uf.weights).to eq({})
  end

  it 'test simple' do
    uf = NetworkX::UnionFind.new([0, 1])
    expect(uf.connected?(0, 1)).to be false

    uf.union(0, 1)
    expect(uf.connected?(0, 1)).to be true
  end

  it 'test []' do
    uf = NetworkX::UnionFind.new([0, 1])
    expect(uf[0] == uf[1]).to be false
    expect(uf[3] == uf[0]).to be false

    uf.union(0, 1)
    uf.union(3, 1)
    expect(uf[0] == uf[1]).to be true
    expect(uf[3] == uf[0]).to be true
    expect(uf[5] == uf[3]).to be false
  end

  it 'test each' do
    uf = NetworkX::UnionFind.new(('a'..'e'))
    uf.union('a', 'd')
    uf.union('d', 'c')
    expect(uf.each.to_a).to eq ('a'..'e').to_a
  end

  it 'test groups' do
    uf = NetworkX::UnionFind.new((0...4))
    groups = uf.groups.map(&:sort).sort
    expect(groups.size).to eq 4
    expect(groups).to eq [[0], [1], [2], [3]]

    uf.union(0, 1)
    uf.union(2, 3)
    groups = uf.groups.map(&:sort).sort
    expect(groups.size).to eq 2
    expect(groups[0]).to eq [0, 1]
    expect(groups[1]).to eq [2, 3]

    uf.union(0, 2)
    groups = uf.groups.map(&:sort).sort
    expect(groups.size).to eq 1
    expect(groups[0]).to eq [0, 1, 2, 3]
  end

  it 'test multiple unite' do
    uf = NetworkX::UnionFind.new((6..15))
    expect(uf[11] == uf[9]).to be false
    expect(uf[9] == uf[10]).to be false
    expect(uf[7] == uf[15]).to be false
    uf.union(9, 6, 15, 10, 8)
    expect(uf[9] == uf[10]).to be true
    uf.union(7, 6, 8)
    expect(uf[7] == uf[15]).to be true
    expect(uf[11] == uf[9]).to be false
  end

  it 'test UnionFind Error node' do
    uf = NetworkX::UnionFind.new(%w[a b c])
    expect { uf.root('x') }.to raise_error(ArgumentError, 'x is not a node')
  end
end
