RSpec.describe NetworkX do
  it 'test arbitrary_element method' do
    expect(NetworkX.arbitrary_element(Set[-1, -2, -3])).to eq -1
    expect(NetworkX.arbitrary_element([10, 20, 30])).to eq 10
    expect(NetworkX.arbitrary_element('xyz')).to eq 'x'
    expect(NetworkX.arbitrary_element({s: 99, t: 100})).to eq :s
    expect(NetworkX.arbitrary_element(80..90)).to eq 80
  end
end
