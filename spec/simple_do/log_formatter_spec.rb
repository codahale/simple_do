require File.dirname(__FILE__) + '/../spec_helper'

require "simple_do/log_formatter"

describe DataObjects::Simple::LogFormatter do
  before(:each) do
    @log_formatter = DataObjects::Simple::LogFormatter.new
  end

  it "should format a log message very nicely" do
    @log_formatter.format("SELECT * FROM blah WHERE id = ?", [1]).should == "  \e[4;36;1mSQL:\e[0m   \e[0;1mSELECT * FROM blah WHERE id = ? \e[0;47;30;1m[1]\e[0m\e[0m"
    @log_formatter.format("SELECT * FROM blah WHERE id = ?", [1]).should == "  \e[4;35;1mSQL:\e[0m   \e[0mSELECT * FROM blah WHERE id = ? \e[0;47;30;1m[1]\e[0m\e[0m"
  end
end