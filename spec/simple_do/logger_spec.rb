require File.dirname(__FILE__) + '/../spec_helper'

require "simple_do/logger"

describe DataObjects::Simple::Logger do
  before(:each) do
    @other_logger = stub(:logger, :debug => nil)
    @logger = DataObjects::Simple::Logger.new(@other_logger)
  end

  it "should format a log message very nicely" do
    @other_logger.should_receive(:debug).with("  \e[4;36;1mSQL:\e[0m   \e[0;1mSELECT * FROM blah WHERE id = ? \e[0;33;1m[1]\e[0m\e[0m")
    @other_logger.should_receive(:debug).with("  \e[4;35;1mSQL:\e[0m   \e[0mSELECT * FROM blah WHERE id = ? \e[0;33;1m[1]\e[0m\e[0m")
    @logger.log("SELECT * FROM blah WHERE id = ?", [1])
    @logger.log("SELECT * FROM blah WHERE id = ?", [1])
  end
end