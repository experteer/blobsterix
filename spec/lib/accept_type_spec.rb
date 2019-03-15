require "spec_helper"

describe Blobsterix::AcceptType do
  include Blobsterix::SpecHelper

  it 'access type without q factor should not fail' do
    expect { Blobsterix::AcceptType.new("image/webp") }.not_to raise_error
  end

  it 'access type with q factor should not fail' do
    expect { Blobsterix::AcceptType.new("application/xml;q=0.9") }.not_to raise_error
  end

  it 'access type with nonvalid q factor should not fail' do
    expect { Blobsterix::AcceptType.new("application/signed-exchange;v=b3") }.not_to raise_error
  end

  context "header field" do
    let(:format) { nil }

    subject {described_class.parse(header, format)}

    context "new chrome header" do
      let(:header) { "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3" }
      it { expect{subject}.to_not raise_error }
    end

    context "old chrome header" do
      let(:header) { "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" }
      it { expect{subject}.to_not raise_error }
    end
  end

end