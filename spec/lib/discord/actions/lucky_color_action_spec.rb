require "./spec/rails_helper"
require "./spec/spec_helper"

describe LuckyColorAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[play], Settings.keyword.lucky_color.sample
  end

  describe "#execute" do
    before do
      allow(HTTP).to receive(:get).and_return(
        OpenStruct.new(
          status: status,
          body: body,
        )
      )
      allow(OpenURI).to receive(:open_uri)
      allow(message_event).to receive(:send_file)
      allow(File).to receive(:open)
      allow(File).to receive(:delete)
      described_class.new.execute(message_event)
    end

    context "when have error" do
      # TODO
    end

    context "when success" do
      let(:status) { 200 }
      let(:body) { '{"items":[{"link":"http://www.example.com/sample.jpg"}]}' }

      it "save activity" do
        expect(Activity.last).to have_attributes(user: author, content: "lucky_color")
      end
    end
  end
end
