require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'logger'

describe MonkeyPatch do
  describe "#for" do
    let(:good_patch) do
      lambda {
        MonkeyPatch.for(:fake_gem, '0.1.1') do |mp|
          mp.announce("testing MonkeyPatch#for")
        end
      }
    end

    let(:patch_for_wrong_version) do
      lambda {
        MonkeyPatch.for(:rspec, "0") do |mp|
          mp.announce("testing MonkeyPatch#for")
        end
      }
    end

    let(:patch_for_missing_gem) do
      lambda {
        MonkeyPatch.for(:this_is_not_a_gem, "1.0") do |mp|
          mp.announce("testing MonkeyPatch#for")
        end
      }
    end

    let(:logger) { Logger.new(nil) }

    context "on correct gem version" do
      subject { good_patch }

      context "with logger set" do
        before { MonkeyPatch.logger = logger }

        it { should_not raise_error }
        it "should announce patch in log file" do
          logger.should_receive(:info).with("MonkeyPatch (fake_gem v0.1.1): testing MonkeyPatch#for")
          subject.call
        end
      end

      context "without logger set" do
        it { should_not raise_error }
        it "should not announce the patch" do
          logger.should_not_receive(:info)
          subject.call
        end
      end
    end

    context "with incorrect gem version" do
      subject { patch_for_wrong_version }
      it { should raise_error(MonkeyPatch::UpdateRequired) }
    end

    context "with missing gem" do
      subject { patch_for_missing_gem }
      it { should raise_error(MonkeyPatch::MissingGem) }
    end
  end
end
