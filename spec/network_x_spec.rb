RSpec.describe NetworkX do
  context 'when has a version number' do
    subject { described_class::VERSION }

    it { is_expected.not_to be(nil) }
  end
end
