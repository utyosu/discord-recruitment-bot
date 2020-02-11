require "./spec/rails_helper"
require "./spec/spec_helper"

describe FoodPornAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", Settings.keyword.food_porn.sample
  end

  describe "#execute" do
    before do
      allow(HTTP).to receive(:get).and_return(
        OpenStruct.new(
          status: status,
          body: body,
        )
      )
    end

    context "when have error" do
      before do
        described_class.new.execute(message_event)
      end

      let(:status) { 404 }
      let(:body) { "" }

      it "save activity" do
        expect(Activity.last).to have_attributes(user: author, content: "food_porn")
      end

      it "have error messagee" do
        expect(message_event).to be_include_message(I18n.t("food_porn.error"))
      end
    end

    context "when success" do
      before do
        allow(OpenURI).to receive(:open_uri)
        allow(message_event).to receive(:send_file)
        allow(File).to receive(:open)
        allow(File).to receive(:delete)
        described_class.new.execute(message_event)
      end

      let(:status) { 200 }
      let(:body) { '{"items":[{"link":"http://www.example.com/sample.jpg"}]}' }

      it "save activity" do
        expect(Activity.last).to have_attributes(user: author, content: "food_porn")
      end

      it "is call send_file" do
        expect(message_event).to have_received(:send_file).once
      end
    end
  end
end
